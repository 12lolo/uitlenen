#!/bin/bash

# SSH connection details
SSH_USER="u540587252"
SSH_HOST="92.113.19.61"
SSH_PORT="65002"
REMOTE_PATH="/home/u540587252/domains/uitleensysteemfirda.nl/public_html"

# Connect to SSH and run commands
ssh -p $SSH_PORT $SSH_USER@$SSH_HOST << 'EOF'
cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html

# Move essentials from public directory to web root
cp public/.htaccess ./.htaccess
cp public/index.php ./index.php
cp public/favicon.ico ./favicon.ico
cp public/robots.txt ./robots.txt

# Create storage symlink manually
if [ ! -L "storage" ]; then
  ln -s $PWD/storage/app/public $PWD/storage
fi

# Update index.php to point to the correct locations
sed -i "s|require __DIR__.'/../vendor/autoload.php'|require __DIR__.'/vendor/autoload.php'|g" index.php
sed -i "s|$app = require_once __DIR__.'/../bootstrap/app.php'|$app = require_once __DIR__.'/bootstrap/app.php'|g" index.php

# Set proper permissions
chmod -R 755 storage bootstrap
chmod -R 777 storage/framework
chmod -R 777 storage/logs
chmod -R 777 bootstrap/cache

# Enable debug mode temporarily to see errors
sed -i "s|APP_DEBUG=false|APP_DEBUG=true|g" .env

# Check logs
echo "### Recent Laravel Error Logs ###"
tail -n 50 storage/logs/laravel.log

echo "### Fix complete ###"
EOF
