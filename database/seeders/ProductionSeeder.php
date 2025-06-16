<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Item;
use App\Models\Loan;
use App\Models\Damage;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class ProductionSeeder extends Seeder
{
    /**
     * Run the database seeds for the production environment.
     * This seeder doesn't rely on factories.
     */
    public function run(): void
    {
        // Create admin user if it doesn't exist
        if (!User::where('email', '252034@student.firda.nl')->exists()) {
            User::create([
                'name' => 'Senne Visser',
                'email' => '252034@student.firda.nl',
                'password' => Hash::make('Uitlenen1!'),
                'is_admin' => true,
                'email_verified_at' => now(),
            ]);
        }

        // Create a test user if it doesn't exist
        if (!User::where('email', 'test@example.com')->exists()) {
            User::create([
                'name' => 'Test User',
                'email' => 'test@example.com',
                'password' => Hash::make('password'),
                'is_admin' => false,
                'email_verified_at' => now(),
            ]);
        }

        // Add more users
        $users = [
            ['name' => 'Jan Jansen', 'email' => 'jan.jansen@firda.nl', 'is_admin' => false],
            ['name' => 'Piet Pietersen', 'email' => 'piet.pietersen@firda.nl', 'is_admin' => true],
            ['name' => 'Klaas Klaassen', 'email' => 'klaas.klaassen@firda.nl', 'is_admin' => false],
            ['name' => 'Emma de Vries', 'email' => 'emma.devries@firda.nl', 'is_admin' => false],
            ['name' => 'Sophie Bakker', 'email' => 'sophie.bakker@firda.nl', 'is_admin' => true],
        ];

        foreach ($users as $userData) {
            if (!User::where('email', $userData['email'])->exists()) {
                User::create([
                    'name' => $userData['name'],
                    'email' => $userData['email'],
                    'password' => Hash::make('password'),
                    'is_admin' => $userData['is_admin'],
                    'email_verified_at' => now(),
                ]);
            }
        }

        // Create categories
        $categories = [
            ['name' => 'Electronics', 'description' => 'Electronic devices and equipment'],
            ['name' => 'Books', 'description' => 'Textbooks and reading materials'],
            ['name' => 'Tools', 'description' => 'Workshop tools and equipment'],
            ['name' => 'Lab Equipment', 'description' => 'Laboratory equipment and supplies'],
            ['name' => 'Sports Equipment', 'description' => 'Athletic and sports gear'],
            ['name' => 'Musical Instruments', 'description' => 'Various musical instruments and accessories'],
            ['name' => 'Art Supplies', 'description' => 'Materials for art and creative projects'],
            ['name' => 'Computer Accessories', 'description' => 'Peripherals and accessories for computers'],
        ];

        foreach ($categories as $categoryData) {
            if (!Category::where('name', $categoryData['name'])->exists()) {
                Category::create($categoryData);
            }
        }

        // Create items
        $items = [
            [
                'title' => 'Dell Laptop',
                'description' => 'Dell Latitude business laptop with Windows 10',
                'status' => 'available',
                'location' => 'IT Room Cabinet 3',
                'photos' => json_encode([]),
                'category_name' => 'Electronics'
            ],
            [
                'title' => 'Projector',
                'description' => 'Epson HD projector with HDMI and VGA inputs',
                'status' => 'available',
                'location' => 'AV Room Shelf 2',
                'photos' => json_encode([]),
                'category_name' => 'Electronics'
            ],
            [
                'title' => 'Chemistry Textbook',
                'description' => 'Introduction to Chemistry, 3rd Edition',
                'status' => 'available',
                'location' => 'Library Section B',
                'photos' => json_encode([]),
                'category_name' => 'Books'
            ],
            [
                'title' => 'Screwdriver Set',
                'description' => 'Professional 12-piece screwdriver set',
                'status' => 'available',
                'location' => 'Workshop Drawer 5',
                'photos' => json_encode([]),
                'category_name' => 'Tools'
            ],
            [
                'title' => 'Microscope',
                'description' => 'Binocular laboratory microscope, 1000x magnification',
                'status' => 'available',
                'location' => 'Science Lab Cabinet 2',
                'photos' => json_encode([]),
                'category_name' => 'Lab Equipment'
            ],
            [
                'title' => 'Basketball',
                'description' => 'Official size basketball',
                'status' => 'available',
                'location' => 'Gym Storage Room',
                'photos' => json_encode([]),
                'category_name' => 'Sports Equipment'
            ],
            [
                'title' => 'Acoustic Guitar',
                'description' => 'Yamaha F310 acoustic guitar',
                'status' => 'available',
                'location' => 'Music Room Cabinet 1',
                'photos' => json_encode([]),
                'category_name' => 'Musical Instruments'
            ],
            [
                'title' => 'Paint Set',
                'description' => 'Acrylic paint set with 24 colors',
                'status' => 'available',
                'location' => 'Art Room Shelf 3',
                'photos' => json_encode([]),
                'category_name' => 'Art Supplies'
            ],
            [
                'title' => 'Wireless Mouse',
                'description' => 'Logitech wireless mouse',
                'status' => 'available',
                'location' => 'IT Storage Room',
                'photos' => json_encode([]),
                'category_name' => 'Computer Accessories'
            ],
            [
                'title' => 'iPad',
                'description' => 'Apple iPad 10th generation',
                'status' => 'available',
                'location' => 'IT Room Cabinet 1',
                'photos' => json_encode([]),
                'category_name' => 'Electronics'
            ],
            [
                'title' => 'HDMI Cable',
                'description' => '2m HDMI cable',
                'status' => 'available',
                'location' => 'AV Room Drawer 1',
                'photos' => json_encode([]),
                'category_name' => 'Electronics'
            ],
            [
                'title' => 'Math Textbook',
                'description' => 'Advanced Calculus, 5th Edition',
                'status' => 'available',
                'location' => 'Library Section A',
                'photos' => json_encode([]),
                'category_name' => 'Books'
            ],
        ];

        foreach ($items as $itemData) {
            if (!Item::where('title', $itemData['title'])->where('description', $itemData['description'])->exists()) {
                $category = Category::where('name', $itemData['category_name'])->first();
                if ($category) {
                    $item = new Item();
                    $item->title = $itemData['title'];
                    $item->description = $itemData['description'];
                    $item->status = $itemData['status'];
                    $item->location = $itemData['location'];
                    $item->photos = $itemData['photos'];
                    $item->category_id = $category->id;
                    $item->save();
                }
            }
        }

        // Create some loans
        $loanedItems = Item::take(5)->get();
        $adminUsers = User::where('is_admin', true)->get();

        if ($adminUsers->count() > 0 && $loanedItems->count() > 0) {
            $studentNames = [
                'Lisa de Jong',
                'Tim van Dijk',
                'Anna Janssen',
                'Daan Visser',
                'Eva Smit',
                'Max Bakker',
                'Julia Meijer',
                'Sam van der Berg',
                'Laura Peters',
                'Thomas Vos'
            ];

            $studentEmails = [
                'lisa.dejong@student.firda.nl',
                'tim.vandijk@student.firda.nl',
                'anna.janssen@student.firda.nl',
                'daan.visser@student.firda.nl',
                'eva.smit@student.firda.nl',
                'max.bakker@student.firda.nl',
                'julia.meijer@student.firda.nl',
                'sam.vanderberg@student.firda.nl',
                'laura.peters@student.firda.nl',
                'thomas.vos@student.firda.nl'
            ];

            // Active loans (not returned)
            foreach ($loanedItems->take(3) as $index => $item) {
                $loan = new Loan();
                $loan->item_id = $item->id;
                $loan->student_name = $studentNames[$index];
                $loan->student_email = $studentEmails[$index];
                $loan->loaned_at = now()->subDays(rand(1, 5));
                $loan->due_date = now()->addDays(rand(1, 14));
                $loan->returned_at = null;
                $loan->notes = rand(0, 1) ? 'Please return in good condition' : null;
                $loan->user_id = $adminUsers->random()->id;
                $loan->returned_to_user_id = null;
                $loan->save();

                // Update item status
                $item->status = 'unavailable';
                $item->save();
            }

            // Historical loans (returned)
            foreach ($loanedItems->skip(3)->take(2) as $index => $item) {
                $loanedAt = now()->subDays(rand(20, 30));
                $dueDate = $loanedAt->copy()->addDays(rand(7, 14));
                $returnedAt = $loanedAt->copy()->addDays(rand(1, 7));

                $loan = new Loan();
                $loan->item_id = $item->id;
                $loan->student_name = $studentNames[$index + 3];
                $loan->student_email = $studentEmails[$index + 3];
                $loan->loaned_at = $loanedAt;
                $loan->due_date = $dueDate;
                $loan->returned_at = $returnedAt;
                $loan->return_notes = rand(0, 1) ? 'Returned in good condition' : null;
                $loan->notes = rand(0, 1) ? 'Student needed it for a project' : null;
                $loan->user_id = $adminUsers->random()->id;
                $loan->returned_to_user_id = $adminUsers->random()->id;
                $loan->save();
            }
        }

        // Create some damage reports
        $availableItems = Item::whereIn('status', ['available'])->take(3)->get();
        
        if ($availableItems->count() > 0 && $adminUsers->count() > 0) {
            $severities = ['minor', 'moderate', 'severe'];
            $descriptions = [
                'minor' => [
                    'Small scratch on the surface',
                    'Minor cosmetic damage',
                    'Slight wear and tear',
                    'Small dent on the corner',
                    'Light scratches on the screen'
                ],
                'moderate' => [
                    'Several scratches and dents',
                    'Button is stuck but still functional',
                    'Screen has visible marks',
                    'Battery drains faster than normal',
                    'Some pages are dog-eared'
                ],
                'severe' => [
                    'Screen is cracked',
                    'Device won\'t power on properly',
                    'Missing several components',
                    'Water damage visible',
                    'Completely unusable'
                ]
            ];
            
            foreach ($availableItems as $index => $item) {
                $severity = $severities[array_rand($severities)];
                
                $damage = new Damage();
                $damage->item_id = $item->id;
                $damage->description = $descriptions[$severity][array_rand($descriptions[$severity])];
                $damage->severity = $severity;
                $damage->student_email = rand(0, 1) ? $studentEmails[array_rand($studentEmails)] : null;
                $damage->photos = json_encode([]);
                $damage->reported_by = $adminUsers->random()->id;
                $damage->save();
            }
        }
    }
}
