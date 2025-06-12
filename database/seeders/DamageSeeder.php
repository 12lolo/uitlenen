<?php

namespace Database\Seeders;

use App\Models\Damage;
use App\Models\Item;
use App\Models\User;
use Illuminate\Database\Seeder;

class DamageSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get items
        $items = Item::all();
        
        if ($items->count() === 0) {
            // Create items if none exist
            $this->call(ItemSeeder::class);
            $items = Item::all();
        }
        
        // Get admin users for damage reporting
        $users = User::where('is_admin', true)->get();
        
        if ($users->count() === 0) {
            // Create an admin user if none exists
            $this->call(UserSeeder::class);
            $users = User::where('is_admin', true)->get();
        }
        
        // Create damage reports for some items (30% of items)
        $damageItems = $items->random($items->count() * 0.3);
        
        foreach ($damageItems as $item) {
            $severity = fake()->randomElement(['minor', 'moderate', 'severe']);
            
            Damage::create([
                'item_id' => $item->id,
                'description' => $this->getDamageDescription($severity),
                'severity' => $severity,
                'student_email' => fake()->optional(0.7)->safeEmail(),
                'photos' => json_encode([]),
                'reported_by' => $users->random()->id,
            ]);
            
            // If damage is severe, possibly add a second damage report
            if ($severity === 'severe' && fake()->boolean(30)) {
                Damage::create([
                    'item_id' => $item->id,
                    'description' => $this->getDamageDescription('moderate'),
                    'severity' => 'moderate',
                    'student_email' => fake()->optional(0.7)->safeEmail(),
                    'photos' => json_encode([]),
                    'reported_by' => $users->random()->id,
                ]);
            }
        }
    }
    
    /**
     * Get a realistic damage description based on severity
     */
    private function getDamageDescription(string $severity): string
    {
        $minorDamages = [
            'Small scratch on the surface',
            'Slight discoloration on one side',
            'Minor wear and tear',
            'Small dent on the corner',
            'Button slightly stiff but functional',
            'Minor cosmetic damage only'
        ];
        
        $moderateDamages = [
            'Several deep scratches on the surface',
            'One component loose but functional',
            'Visible wear on most parts',
            'Moderate dent affecting appearance',
            'Screen has minor crack but is usable',
            'Case is damaged but internals unaffected'
        ];
        
        $severeDamages = [
            'Item dropped and multiple components damaged',
            'Water damage affecting functionality',
            'Screen severely cracked and partially unusable',
            'Unit powers on but shuts down unexpectedly',
            'Major component broken, needs repair',
            'Several parts missing, cannot be used properly'
        ];
        
        switch ($severity) {
            case 'minor':
                return fake()->randomElement($minorDamages);
            case 'moderate':
                return fake()->randomElement($moderateDamages);
            case 'severe':
                return fake()->randomElement($severeDamages);
            default:
                return 'Unknown damage';
        }
    }
}
