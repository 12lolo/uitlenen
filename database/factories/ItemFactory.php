<?php

namespace Database\Factories;

use App\Models\Category;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Item>
 */
class ItemFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'title' => $this->faker->sentence(3),
            'description' => $this->faker->paragraph(),
            'category_id' => Category::factory(),
            'photos' => json_encode([]),
            'status' => $this->faker->randomElement(['available', 'unavailable']),
            'location' => $this->faker->word() . ' shelf',
            'inventory_number' => $this->faker->unique()->numerify('INV-####'),
        ];
    }
}
