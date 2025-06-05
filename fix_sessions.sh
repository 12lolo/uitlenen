#!/bin/bash

# SSH connection details
SSH_USER="u540587252"
SSH_HOST="92.113.19.61"
SSH_PORT="65002"

# Connect to SSH and run commands
ssh -p $SSH_PORT $SSH_USER@$SSH_HOST << 'EOF'
cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html

# Create sessions table migration
cat > create_sessions_table_migration.php << 'ENDMIGRATION'
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

# Run migration manually
php artisan migrate --path=./create_sessions_table_migration.php

# Update index.php if needed
if [ -f "public/index.php" ] && [ -f "index.php" ]; then
  cp public/index.php ./index.php
  sed -i "s|require __DIR__.'/../vendor/autoload.php'|require __DIR__.'/vendor/autoload.php'|g" index.php
  sed -i "s|$app = require_once __DIR__.'/../bootstrap/app.php'|$app = require_once __DIR__.'/bootstrap/app.php'|g" index.php
fi

# Get more detailed error information
echo "### Full Laravel Error Log ###"
head -n 50 storage/logs/laravel.log

echo "### Fixing session issue complete ###"
EOF
