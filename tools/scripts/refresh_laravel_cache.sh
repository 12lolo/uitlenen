#!/bin/bash

# Script to refresh Laravel middleware caches and configurations
echo "Refreshing Laravel middleware caches and configurations..."

# Change to the project root directory
cd /home/senne/projects/uitlenen

# Clear all Laravel caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear

# Rebuild the Laravel caches
php artisan config:cache
php artisan route:cache

echo "Cache refresh complete!"
