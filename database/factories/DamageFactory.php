<?php

namespace Database\Factories;

use App\Models\Item;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Damage>
 */
class DamageFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'item_id' => Item::factory(),
            'description' => $this->faker->paragraph(),
            'severity' => $this->faker->randomElement(['minor', 'moderate', 'severe']),
            'student_email' => $this->faker->optional(0.7)->email(), // 70% chance of having a student email
            'photos' => json_encode([]),
            'reported_by' => User::factory(),
        ];
    }
}
