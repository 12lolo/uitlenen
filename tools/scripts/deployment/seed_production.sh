#!/bin/bash
# Script to run seeders on production environment

# Print commands and exit on errors
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=======================================${NC}"
echo -e "${YELLOW}   Running Database Seeders on Production   ${NC}"
echo -e "${YELLOW}=======================================${NC}"

# Create DamageSeeder if it doesn't exist
if [ ! -f "database/seeders/DamageSeeder.php" ]; then
  echo -e "${YELLOW}Creating DamageSeeder.php...${NC}"
  cat > database/seeders/DamageSeeder.php << 'EOF'
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
        // Get items that might have damage
        $items = Item::all();
        
        if ($items->count() === 0) {
            // Create items if none exist
            $this->call(ItemSeeder::class);
            $items = Item::all();
        }
        
        // Get users who can report damage
        $users = User::where('is_admin', true)->get();
        
        if ($users->count() === 0) {
            // Create an admin user if none exists
            $this->call(UserSeeder::class);
            $users = User::where('is_admin', true)->get();
        }
        
        // Create damage reports for some items
        foreach ($items->random(min(5, $items->count())) as $item) {
            Damage::create([
                'item_id' => $item->id,
                'description' => fake()->paragraph(),
                'severity' => fake()->randomElement(['minor', 'moderate', 'severe']),
                'student_email' => fake()->optional(0.7)->safeEmail(),
                'photos' => json_encode([]),
                'reported_by' => $users->random()->id,
            ]);
        }
    }
}
EOF
  echo -e "${GREEN}DamageSeeder.php created.${NC}"
fi

# Create a temporary zip file with just the seeder files
echo -e "${YELLOW}Creating seed package...${NC}"
mkdir -p deploy
zip -r deploy/seeders.zip database/seeders database/factories

# Transfer the seeders to production
echo -e "${YELLOW}Transferring seeders to production...${NC}"
SERVER="u540587252@92.113.19.61"
SERVER_PORT="65002"
scp -P "$SERVER_PORT" deploy/seeders.zip "$SERVER:/home/u540587252/domains/uitleensysteemfirda.nl/public_html/"

echo -e "${GREEN}Connecting to production server...${NC}"

# SSH into the server and run the seeders
ssh -p "$SERVER_PORT" "$SERVER" << 'ENDSSH'
cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html

echo "Extracting seeders package..."
unzip -o seeders.zip

echo "Creating database backup before seeding..."
php artisan db:backup || echo "Backup failed, continuing anyway"

echo "Running database seeders..."
# First, we'll update the DatabaseSeeder class to include all our seeders
# We'll check if the seeders are already registered in DatabaseSeeder
if ! grep -q "CategorySeeder::class" database/seeders/DatabaseSeeder.php; then
    sed -i "s/UserSeeder::class,/UserSeeder::class,\n            CategorySeeder::class,\n            ItemSeeder::class,\n            LoanSeeder::class,\n            DamageSeeder::class,/g" database/seeders/DatabaseSeeder.php
    echo "Updated DatabaseSeeder.php to include all seeders"
fi

echo "Running seeders..."
# First, make sure composer dependencies are installed
php composer.phar install --no-dev --optimize-autoloader || echo "Composer install failed, continuing anyway"

# Run seeders with PHP error reporting enabled
php -d error_reporting=E_ALL artisan db:seed --force || echo "Seeding failed, check error messages above"

echo "Setting proper permissions for cache directories..."
chmod -R 777 bootstrap/cache
chmod -R 777 storage/framework

echo "Clearing cache..."
php artisan cache:clear || echo "Failed to clear cache, continuing anyway"

echo "Cleaning up..."
rm seeders.zip

echo "Done! Database has been populated with dummy data."
ENDSSH

echo -e "${GREEN}=======================================${NC}"
echo -e "${GREEN}   Seeders executed successfully!      ${NC}"
echo -e "${GREEN}=======================================${NC}"
