#!/bin/bash
# Deployment script for Laravel application to shared hosting

# Print commands and exit on errors
set -e

# Source directory (local)
SRC_DIR="/home/senne/projects/uitlenen"

# Target server information
SERVER="u540587252@92.113.19.61"
SERVER_PORT="65002"
DEST_DIR="/home/u540587252/domains/uitleensysteemfirda.nl/public_html"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Starting deployment process ===${NC}"

# 1. Prepare the application for production
echo -e "${YELLOW}Preparing Laravel application for production...${NC}"
cd "$SRC_DIR"
# Skip optimize:clear as it requires the cache table
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 2. Create production zip file
echo -e "${YELLOW}Creating deployment package...${NC}"
mkdir -p "$SRC_DIR/deploy"
cd "$SRC_DIR"
zip -r deploy/deploy.zip . -x "node_modules/*" "vendor/*" ".git/*" ".github/*" "tests/*" "storage/logs/*" "storage/framework/cache/*" "storage/framework/sessions/*" "storage/framework/views/*" "storage/app/public/*" "bootstrap/cache/*" ".env" "deploy/*" 

# 3. Transfer the deployment package
echo -e "${YELLOW}Transferring files to server...${NC}"
scp -P "$SERVER_PORT" "$SRC_DIR/deploy/deploy.zip" "$SERVER:$DEST_DIR/"
scp -P "$SERVER_PORT" "$SRC_DIR/.env.production" "$SERVER:$DEST_DIR/.env"

# 4. Connect to the server and set up the application
echo -e "${YELLOW}Setting up the application on the server...${NC}"
ssh -p "$SERVER_PORT" "$SERVER" << 'ENDSSH'
cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html
unzip -o deploy.zip
rm deploy.zip

# Create necessary directories
mkdir -p bootstrap/cache
mkdir -p storage/app/public
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/framework/testing
mkdir -p storage/framework/views

# Set proper permissions
chmod -R 755 storage bootstrap/cache
chmod -R 777 storage/framework
chmod -R 777 storage/logs
chmod -R 777 bootstrap/cache

# Install Composer and dependencies
php -r "readfile('https://getcomposer.org/installer');" | php
php composer.phar install --no-dev --optimize-autoloader

# Run Laravel artisan commands
php artisan migrate --force
php artisan storage:link
php artisan optimize

# Clear all caches
php artisan optimize:clear

# Re-cache config and routes for production
php artisan config:cache
php artisan route:cache

echo "Deployment completed!"
ENDSSH

echo -e "${GREEN}=== Deployment completed successfully ===${NC}"
