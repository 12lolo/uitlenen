#!/bin/bash
# Streamlined deployment script for Laravel application to shared hosting
# This script incorporates all lessons learned from previous deployments

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
# Clear all caches first
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear

# Generate optimized production assets if needed
# npm ci
# npm run build

# 2. Create production zip file
echo -e "${YELLOW}Creating deployment package...${NC}"
mkdir -p "$SRC_DIR/deploy"
cd "$SRC_DIR"

if [ -f "deployment-include.txt" ]; then
    # Use the include file to create a more targeted deployment package
    echo -e "${YELLOW}Using deployment-include.txt for selective packaging...${NC}"
    zip -r deploy/deploy.zip -@ < deployment-include.txt
else
    # Fall back to exclude-based approach if include file doesn't exist
    echo -e "${YELLOW}Using exclude list for packaging...${NC}"
    zip -r deploy/deploy.zip . -x "node_modules/*" "vendor/*" ".git/*" ".github/*" "tests/*" \
        "storage/logs/*" "storage/framework/cache/*" "storage/framework/sessions/*" \
        "storage/framework/views/*" "storage/app/public/*" "bootstrap/cache/*" \
        ".env" "deploy/*" "*_*.sh" "phpunit.xml" ".idea/*" ".vscode/*" \
        "documentation/*" ".editorconfig" ".gitattributes" ".gitignore" \
        "README.md" "cleanup_summary.md" "DEPLOYMENT.md" "scripts_to_remove.md" \
        "package.json" "package-lock.json" "composer.lock" "vite.config.js"
fi

# 3. Transfer the deployment package
echo -e "${YELLOW}Transferring files to server...${NC}"
scp -P "$SERVER_PORT" "$SRC_DIR/deploy/deploy.zip" "$SERVER:$DEST_DIR/"
scp -P "$SERVER_PORT" "$SRC_DIR/.env.production" "$SERVER:$DEST_DIR/.env"
scp -P "$SERVER_PORT" "$SRC_DIR/cleanup_files_production.sh" "$SERVER:$DEST_DIR/"

# 4. Connect to the server and set up the application
echo -e "${YELLOW}Setting up the application on the server...${NC}"
ssh -p "$SERVER_PORT" "$SERVER" << 'ENDSSH'
cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html

# Backup database before migration (optional)
php -r "if(file_exists('artisan')){ echo shell_exec('php artisan db:backup'); }"

# Extract new files
unzip -o deploy.zip
rm deploy.zip

# Create necessary directories
mkdir -p bootstrap/cache
mkdir -p storage/app/public
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/framework/testing
mkdir -p storage/framework/views
mkdir -p storage/logs

# Create necessary log files
touch storage/logs/laravel.log
touch storage/logs/scheduler.log
touch storage/logs/reminder-due.log
touch storage/logs/reminder-overdue.log
touch storage/logs/prune-invitations.log
touch storage/logs/storage-structure.log

# Set proper permissions
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
chmod 755 artisan
chmod -R 777 storage/framework
chmod -R 777 storage/logs
chmod -R 777 bootstrap/cache

# Move essential files from public to root for shared hosting
if [ -f "public/index.php" ] && [ ! -f "index.php" ]; then
  cp public/.htaccess ./.htaccess
  cp public/index.php ./index.php
  cp public/favicon.ico ./favicon.ico 2>/dev/null || true
  cp public/robots.txt ./robots.txt 2>/dev/null || true
  
  # Update index.php to point to the correct locations
  sed -i "s|require __DIR__.'/../vendor/autoload.php'|require __DIR__.'/vendor/autoload.php'|g" index.php
  sed -i "s|\$app = require_once __DIR__.'/../bootstrap/app.php'|\$app = require_once __DIR__.'/bootstrap/app.php'|g" index.php
fi

# Create storage symlink
if [ ! -L "storage" ]; then
  ln -s $PWD/storage/app/public $PWD/storage
fi

# Install Composer and dependencies if needed
if [ ! -d "vendor" ]; then
  curl -sS https://getcomposer.org/installer | php
  php composer.phar install --no-dev --optimize-autoloader
  rm composer.phar
fi

# Run Laravel artisan commands
php artisan migrate --force
php artisan storage:link || true  # May fail on shared hosting, we handled it manually above
php artisan optimize

# Turn off debug mode for security
sed -i "s/APP_DEBUG=true/APP_DEBUG=false/g" .env

# Run cleanup script to remove unnecessary files (if exists)
if [ -f "cleanup_files_production.sh" ]; then
  echo "Running cleanup script to remove unnecessary files..."
  chmod +x cleanup_files_production.sh
  ./cleanup_files_production.sh
fi

echo "Deployment completed successfully!"
ENDSSH

# 5. Clean up local temporary files
rm -rf "$SRC_DIR/deploy/deploy.zip"

echo -e "${GREEN}=== Deployment completed successfully ===${NC}"
echo -e "${GREEN}Your application is now live at https://uitleensysteemfirda.nl${NC}"
