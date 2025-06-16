#!/bin/bash
# Simple script to transfer and run seeders on production

# Print commands and exit on errors
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Server information
SERVER="u540587252@92.113.19.61"
SERVER_PORT="65002"
DEST_DIR="/home/u540587252/domains/uitleensysteemfirda.nl/public_html"

echo -e "${YELLOW}Transferring seeders to production...${NC}"
scp -P "$SERVER_PORT" "/home/senne/projects/uitlenen/deploy/seeders.zip" "$SERVER:$DEST_DIR/"

echo -e "${YELLOW}Running seeders on production...${NC}"
ssh -p "$SERVER_PORT" "$SERVER" << 'ENDSSH'
cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html

echo "Extracting seeders..."
unzip -o seeders.zip
rm seeders.zip

echo "Running database seeders..."
php artisan db:seed --force

echo "Done! Database has been populated with dummy data."
ENDSSH

echo -e "${GREEN}Seeders executed successfully!${NC}"
