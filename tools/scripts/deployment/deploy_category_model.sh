#!/bin/bash
# Script to deploy Category model changes to production

# Set error handling
set -e

# Variables
SERVER="u540587252@92.113.19.61"
SERVER_PORT="65002"
DEST_DIR="/home/u540587252/domains/uitleensysteemfirda.nl/public_html"
SOURCE_DIR="/home/senne/projects/uitlenen"

# Explanation
echo "=== Deploying Category model changes to production ==="
echo "This script will copy the updated Category model to production"
echo ""

# Create zip of the model
echo "Creating model package..."
mkdir -p "$SOURCE_DIR/deploy"
cd "$SOURCE_DIR"
zip -r deploy/category_model.zip app/Models/Category.php

# Transfer the model to production
echo "Transferring model to production..."
scp -P "$SERVER_PORT" "$SOURCE_DIR/deploy/category_model.zip" "$SERVER:$DEST_DIR/"

# Connect to server and extract the model
echo "Extracting model on production..."
ssh -p "$SERVER_PORT" "$SERVER" << 'ENDSSH'
cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html

# Extract model
unzip -o category_model.zip
rm category_model.zip

# Clear caches
php artisan config:clear
php artisan route:clear
php artisan cache:clear
php artisan view:clear
php artisan optimize

echo "Category model deployment completed successfully!"
ENDSSH

# Clean up
rm -rf "$SOURCE_DIR/deploy/category_model.zip"

echo "=== Category model deployment completed ==="
