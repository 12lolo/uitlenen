<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create some predefined categories
        $categories = [
            [
                'name' => 'Electronics',
                'description' => 'Electronic devices and equipment'
            ],
            [
                'name' => 'Books',
                'description' => 'Textbooks and reading materials'
            ],
            [
                'name' => 'Tools',
                'description' => 'Workshop tools and equipment'
            ],
            [
                'name' => 'Lab Equipment',
                'description' => 'Laboratory equipment and supplies'
            ],
            [
                'name' => 'Sports Equipment',
                'description' => 'Athletic and sports gear'
            ],
        ];

        foreach ($categories as $category) {
            Category::create($category);
        }

        // Create some additional random categories
        Category::factory()->count(5)->create();
    }
}
