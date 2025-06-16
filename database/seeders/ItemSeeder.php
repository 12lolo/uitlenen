<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Item;
use Illuminate\Database\Seeder;

class ItemSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get all categories
        $categories = Category::all();
        
        if ($categories->count() === 0) {
            // Create a default category if none exists
            $this->call(CategorySeeder::class);
            $categories = Category::all();
        }
        
        // Create some predefined items
        $items = [
            [
                'title' => 'Dell Laptop',
                'description' => 'Dell Latitude business laptop with Windows 10',
                'status' => 'available',
                'location' => 'IT Room Cabinet 3',
                'inventory_number' => 'INV-1001',
                'photos' => json_encode([]),
                'category_id' => $categories->where('name', 'Electronics')->first()?->id ?? $categories->first()->id
            ],
            [
                'title' => 'Projector',
                'description' => 'Epson HD projector with HDMI and VGA inputs',
                'status' => 'available',
                'location' => 'AV Room Shelf 2',
                'inventory_number' => 'INV-1002',
                'photos' => json_encode([]),
                'category_id' => $categories->where('name', 'Electronics')->first()?->id ?? $categories->first()->id
            ],
            [
                'title' => 'Chemistry Textbook',
                'description' => 'Introduction to Chemistry, 3rd Edition',
                'status' => 'available',
                'location' => 'Library Section B',
                'inventory_number' => 'INV-2001',
                'photos' => json_encode([]),
                'category_id' => $categories->where('name', 'Books')->first()?->id ?? $categories->first()->id
            ],
            [
                'title' => 'Screwdriver Set',
                'description' => 'Professional 12-piece screwdriver set',
                'status' => 'available',
                'location' => 'Workshop Drawer 5',
                'inventory_number' => 'INV-3001',
                'photos' => json_encode([]),
                'category_id' => $categories->where('name', 'Tools')->first()?->id ?? $categories->first()->id
            ],
            [
                'title' => 'Microscope',
                'description' => 'Binocular laboratory microscope, 1000x magnification',
                'status' => 'available',
                'location' => 'Science Lab Cabinet 2',
                'inventory_number' => 'INV-4001',
                'photos' => json_encode([]),
                'category_id' => $categories->where('name', 'Lab Equipment')->first()?->id ?? $categories->first()->id
            ],
        ];

        foreach ($items as $item) {
            Item::create($item);
        }

        // Create additional random items for each category
        foreach ($categories as $category) {
            Item::factory()->count(5)->create([
                'category_id' => $category->id
            ]);
        }
    }
}
