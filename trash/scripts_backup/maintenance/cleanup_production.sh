#!/bin/bash

# Cleanup script for production server after Laravel 12 admin fix
# This script removes temporary files and verifies the fix

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# SSH connection details
SSH_USER="u540587252"
SSH_HOST="92.113.19.61"
SSH_PORT="65002"
REMOTE_PATH="/home/u540587252/domains/uitleensysteemfirda.nl/public_html"

echo -e "${YELLOW}===== CLEANING UP PRODUCTION SERVER AFTER ADMIN FIX =====${NC}"

# Connect to SSH and run cleanup commands
ssh -p $SSH_PORT $SSH_USER@$SSH_HOST << 'EOF'
cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html

echo "=== Starting cleanup process ==="

# Remove Laravel 12 admin fix temporary files
echo "Removing Laravel 12 admin fix temporary files..."
rm -f fix_laravel_middleware.php
rm -f fix_laravel12_middleware.php
rm -f verify_laravel12_fix.php
rm -f laravel12_admin_test.php
rm -f test_laravel12_routes.php
rm -f fix_laravel12_routes.php
rm -f quick_admin_test.php
rm -f improved_verify_server_fix.php
rm -f admin_fix_verify.php
rm -f test_middleware_resolution.php
rm -f final_admin_route_fix.php
rm -rf laravel12_fix
rm -rf .github
rm -rf node_modules
rm -f package-lock.json
rm -f yarn.lock

# Remove development files (optional)
echo "Removing development-only files..."
rm -f phpunit.xml
rm -f vite.config.js
rm -f webpack.mix.js
rm -f .editorconfig
rm -f .gitattributes
rm -f .gitignore
rm -rf .idea
rm -rf .vscode
rm -rf deploy

# Set correct permissions
echo "Setting correct file permissions..."
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
chmod 755 artisan

# Make storage and bootstrap/cache writable
chmod -R 777 storage/framework
chmod -R 777 storage/logs
chmod -R 777 bootstrap/cache

# Turn off debug mode for security
echo "Updating environment settings..."
sed -i "s/APP_DEBUG=true/APP_DEBUG=false/g" .env

# Clear all caches and optimize
echo "Optimizing Laravel application..."
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan optimize:clear
# Rebuild optimized versions
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize

echo "=== Cleanup process completed ==="
echo "Your production environment is now optimized."
EOF

echo "Server cleanup completed!"
