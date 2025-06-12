<?php

namespace Database\Factories;

use App\Models\Item;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Loan>
 */
class LoanFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $loanedAt = $this->faker->dateTimeBetween('-30 days', 'now');
        $dueDate = $this->faker->dateTimeBetween($loanedAt, '+30 days');
        $isReturned = $this->faker->boolean(70); // 70% chance the item is returned
        
        return [
            'item_id' => Item::factory(),
            'student_name' => $this->faker->name(),
            'student_email' => $this->faker->email(),
            'loaned_at' => $loanedAt,
            'due_date' => $dueDate,
            'returned_at' => $isReturned ? $this->faker->dateTimeBetween($loanedAt, 'now') : null,
            'return_notes' => $isReturned ? $this->faker->optional(0.5)->sentence() : null,
            'notes' => $this->faker->optional(0.5)->sentence(),
            'user_id' => User::factory(),
            'returned_to_user_id' => $isReturned ? User::factory() : null,
        ];
    }
}
