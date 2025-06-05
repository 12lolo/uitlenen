#!/bin/bash

# Cleanup script for production server
# This script removes unnecessary development and testing files from production

# SSH connection details
SSH_USER="u540587252"
SSH_HOST="92.113.19.61"
SSH_PORT="65002"

echo "Connecting to production server to clean up unnecessary files..."

# Connect to SSH and run cleanup commands
ssh -p $SSH_PORT $SSH_USER@$SSH_HOST << 'EOF'
cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html

echo "=== Starting cleanup process ==="

# Remove unnecessary testing and troubleshooting files
echo "Removing testing and troubleshooting files..."
rm -f test_*.sh
rm -f setup_*.sh
rm -f fix_*.sh
rm -f final_*.sh
rm -f create_sessions_table_migration.php
rm -f migrations-fix.md
rm -f deploy.sh
rm -f deploy.zip
rm -f composer.phar
rm -rf tests
rm -rf .git
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
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize

echo "=== Cleanup process completed ==="
echo "Your production environment is now optimized."
EOF

echo "Server cleanup completed!"
