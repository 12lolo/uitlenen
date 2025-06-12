#!/bin/bash
# Post-deployment tasks

# Clear Laravel cache
php artisan optimize:clear
php artisan cache:clear
php artisan config:clear
php artisan route:clear

echo "Cache cleared successfully."
echo "Deployment complete - please run the verification script next."
