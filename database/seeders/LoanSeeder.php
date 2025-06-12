<?php

namespace Database\Seeders;

use App\Models\Item;
use App\Models\Loan;
use App\Models\User;
use Illuminate\Database\Seeder;

class LoanSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get available items
        $items = Item::where('status', 'available')->get();
        
        if ($items->count() === 0) {
            // Create items if none exist
            $this->call(ItemSeeder::class);
            $items = Item::where('status', 'available')->get();
        }
        
        // Get admin users for loan management
        $users = User::where('is_admin', true)->get();
        
        if ($users->count() === 0) {
            // Create an admin user if none exists
            $this->call(UserSeeder::class);
            $users = User::where('is_admin', true)->get();
        }
        
        // Create some active loans (not returned)
        foreach (range(1, 5) as $i) {
            if ($items->count() > 0) {
                $randomItem = $items->random();
                
                Loan::create([
                    'item_id' => $randomItem->id,
                    'student_name' => fake()->name(),
                    'student_email' => fake()->unique()->safeEmail(),
                    'loaned_at' => fake()->dateTimeBetween('-10 days', 'now'),
                    'due_date' => fake()->dateTimeBetween('+1 day', '+14 days'),
                    'returned_at' => null,
                    'notes' => fake()->optional(0.7)->sentence(),
                    'user_id' => $users->random()->id,
                    'returned_to_user_id' => null,
                ]);
                
                // Update item status to unavailable
                $randomItem->status = 'unavailable';
                $randomItem->save();
                
                // Remove this item from our collection
                $items = $items->where('id', '!=', $randomItem->id);
            }
        }
        
        // Create some historical loans (returned)
        foreach (range(1, 10) as $i) {
            if ($items->count() > 0) {
                $randomItem = $items->random();
                
                $loanedAt = fake()->dateTimeBetween('-60 days', '-15 days');
                $dueDate = fake()->dateTimeBetween($loanedAt, '+14 days');
                $returnedAt = fake()->dateTimeBetween($loanedAt, $dueDate);
                
                Loan::create([
                    'item_id' => $randomItem->id,
                    'student_name' => fake()->name(),
                    'student_email' => fake()->unique()->safeEmail(),
                    'loaned_at' => $loanedAt,
                    'due_date' => $dueDate,
                    'returned_at' => $returnedAt,
                    'return_notes' => fake()->optional(0.5)->sentence(),
                    'notes' => fake()->optional(0.7)->sentence(),
                    'user_id' => $users->random()->id,
                    'returned_to_user_id' => $users->random()->id,
                ]);
            }
        }
    }
}
