#!/bin/bash

# SSH connection details
SSH_USER="u540587252"
SSH_HOST="92.113.19.61"
SSH_PORT="65002"

# Connect to SSH and run commands
ssh -p $SSH_PORT $SSH_USER@$SSH_HOST << 'EOF'
cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html

echo "### Creating ProductionUserSeeder ###"
cat > database/seeders/ProductionUserSeeder.php << 'ENDSEEDER'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class ProductionUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::create([
            'name' => 'Senne Visser',
            'email' => '252034@student.firda.nl',
            'email_verified_at' => now(),
            'password' => Hash::make('Uitlenen1!'),
            'is_admin' => true,
            'setup_completed' => true,
            'remember_token' => Str::random(10),
        ]);
        
        $this->command->info('Admin user created successfully!');
    }
}
ENDSEEDER

# Run the seeder
php artisan db:seed --class=ProductionUserSeeder --force

echo "### Setting up Laravel file structure ###"
# Move public directory contents to web root
cp -n public/* ./

# Update paths in index.php
sed -i "s|require __DIR__.'/../vendor/autoload.php'|require __DIR__.'/vendor/autoload.php'|g" index.php
sed -i "s|$app = require_once __DIR__.'/../bootstrap/app.php'|$app = require_once __DIR__.'/bootstrap/app.php'|g" index.php

echo "### FINAL OPTIMIZATIONS ###"
php artisan optimize
php artisan view:cache

echo "### SETUP COMPLETE ###"
echo "Visit your website at https://uitleensysteemfirda.nl"
EOF
