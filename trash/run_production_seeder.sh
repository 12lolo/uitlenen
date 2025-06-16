#!/bin/bash
# Script to run the production seeder on the server

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

echo -e "${GREEN}=== Starting production seeder deployment ===${NC}"

# First, transfer the production seeder file
echo -e "${YELLOW}Transferring production seeder file...${NC}"
scp -P "$SERVER_PORT" "$SRC_DIR/database/seeders/ProductionSeeder.php" "$SERVER:$DEST_DIR/database/seeders/"

# Connect to the server and run the seeder
echo -e "${YELLOW}Running the production seeder on the server...${NC}"
ssh -p "$SERVER_PORT" "$SERVER" << 'ENDSSH'
cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html

# Run the production seeder with force flag
php artisan db:seed --class=ProductionSeeder --force

echo "Production seeder completed successfully!"
ENDSSH

echo -e "${GREEN}=== Production seeder deployment completed successfully ===${NC}"
