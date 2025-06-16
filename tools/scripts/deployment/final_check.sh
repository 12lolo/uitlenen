#!/bin/bash

# SSH connection details
SSH_USER="u540587252"
SSH_HOST="92.113.19.61"
SSH_PORT="65002"

# Connect to SSH and run commands
ssh -p $SSH_PORT $SSH_USER@$SSH_HOST << 'EOF'
cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html

# Set permissions one last time
chmod -R 755 storage bootstrap
chmod -R 777 storage/framework
chmod -R 777 storage/logs
chmod -R 777 bootstrap/cache

# Create symbolic link for storage
ln -sf $PWD/storage/app/public $PWD/public/storage
ln -sf $PWD/storage/app/public $PWD/storage

# Clear all caches and optimize again
php artisan view:clear
php artisan route:clear
php artisan config:clear
php artisan cache:clear
php artisan optimize

# Show current session driver
echo "### Current Session Driver: ###"
grep -n "SESSION_DRIVER" .env

# Check if the sessions table exists
echo "### Checking Sessions Table: ###"
php artisan tinker --execute="try { Schema::hasTable('sessions') ? print('Sessions table exists!') : print('Sessions table DOES NOT exist!'); } catch(\Exception \$e) { print(\$e->getMessage()); }"

# Make sure DatabaseSessionHandler is available
echo "### Database sessions supported: ###"
php artisan tinker --execute="print(class_exists('Illuminate\Session\DatabaseSessionHandler') ? 'Yes' : 'No');"

echo "### Final check complete ###"
EOF
