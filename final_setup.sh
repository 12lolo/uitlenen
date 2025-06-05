#!/bin/bash

# SSH connection details
SSH_USER="u540587252"
SSH_HOST="92.113.19.61"
SSH_PORT="65002"

# Connect to SSH and run commands
ssh -p $SSH_PORT $SSH_USER@$SSH_HOST << 'EOF'
cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html

echo "### STEP 1: Fixing directory permissions ###"
mkdir -p bootstrap/cache
chmod -R 777 bootstrap/cache
mkdir -p storage/logs
chmod -R 777 storage/logs
mkdir -p storage/framework/{cache,sessions,views}
chmod -R 777 storage/framework

echo "### STEP 2: Setting up Laravel for web root ###"
# Copy necessary files from public to root
if [ ! -f "index.php" ]; then
  cp public/index.php ./index.php
  cp public/.htaccess ./.htaccess
  cp -n public/* ./
fi

# Update paths in index.php
sed -i "s|require __DIR__.'/../vendor/autoload.php'|require __DIR__.'/vendor/autoload.php'|g" index.php
sed -i "s|$app = require_once __DIR__.'/../bootstrap/app.php'|$app = require_once __DIR__.'/bootstrap/app.php'|g" index.php

echo "### STEP 3: Creating sessions migration ###"
cat > database/migrations/$(date +%Y_%m_%d_%H%M%S)_create_sessions_table.php << 'ENDMIGRATION'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('sessions', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('user_id')->nullable()->index();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->longText('payload');
            $table->integer('last_activity')->index();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('sessions');
    }
};
ENDMIGRATION

echo "### STEP 4: Running migrations ###"
php artisan migrate --force

echo "### STEP 5: Create symbolic link for storage ###"
if [ ! -L "storage" ]; then
  ln -sf $PWD/storage/app/public $PWD/storage
fi

echo "### STEP 6: Set up admin user ###"
php artisan db:seed --class=ProductionUserSeeder --force

echo "### STEP 7: Clear and optimize application ###"
php artisan view:clear
php artisan route:clear
php artisan config:clear
php artisan cache:clear

echo "### STEP 8: Optimize application ###"
php artisan optimize

echo "### SETUP COMPLETE ###"
echo "You can now access your application at https://uitleensysteemfirda.nl"
EOF
