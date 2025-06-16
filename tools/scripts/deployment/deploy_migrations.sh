#!/bin/bash
# Script to deploy migrations and run them on production

# Set error handling
set -e

# Variables
SERVER="u540587252@92.113.19.61"
SERVER_PORT="65002"
DEST_DIR="/home/u540587252/domains/uitleensysteemfirda.nl/public_html"
SOURCE_DIR="/home/senne/projects/uitlenen"

# Explanation
echo "=== Deploying migrations to production ==="
echo "This script will:"
echo "1. Copy the new migration to the production server"
echo "2. Run the migration on the production server"
echo ""

# Create zip of migrations
echo "Creating migrations package..."
mkdir -p "$SOURCE_DIR/deploy"
cd "$SOURCE_DIR"
zip -r deploy/migrations.zip database/migrations/2025_06_11_000001_add_fields_to_items_table.php

# Transfer the migrations to production
echo "Transferring migrations to production..."
scp -P "$SERVER_PORT" "$SOURCE_DIR/deploy/migrations.zip" "$SERVER:$DEST_DIR/"

# Connect to server and run migrations
echo "Running migrations on production..."
ssh -p "$SERVER_PORT" "$SERVER" << 'ENDSSH'
cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html

# Extract migrations
unzip -o migrations.zip
rm migrations.zip

# Run migrations
php artisan migrate --force

echo "Migrations completed successfully!"
ENDSSH

# Clean up
rm -rf "$SOURCE_DIR/deploy/migrations.zip"

echo "=== Migration deployment completed ==="
