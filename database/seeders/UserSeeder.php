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
        User::factory()->create([
            'name' => 'Senne Visser',
            'email' => '252034@student.firda.nl',
            'password' => Hash::make('Uitlenen1!'),
            'is_admin' => true,
            'email_verified_at' => now(),
        ]);
    }
}
