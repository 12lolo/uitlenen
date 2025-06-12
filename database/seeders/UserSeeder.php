<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create admin user if it doesn't exist already
        if (!User::where('email', '252034@student.firda.nl')->exists()) {
            User::factory()->create([
                'name' => 'Senne Visser',
                'email' => '252034@student.firda.nl',
                'password' => Hash::make('Uitlenen1!'),
                'is_admin' => true,
                'email_verified_at' => now(),
            ]);
        }
        
        // Create some regular users for testing
        User::factory()->count(5)->create([
            'is_admin' => false,
            'email_verified_at' => now(),
        ]);
        
        // Create another admin user for testing
        if (!User::where('email', 'admin@firda.nl')->exists()) {
            User::factory()->create([
                'name' => 'Admin User',
                'email' => 'admin@firda.nl',
                'password' => Hash::make('Admin123!'),
                'is_admin' => true,
                'email_verified_at' => now(),
            ]);
        }
    }
}
