#!/bin/bash
# Upload script for admin fix

# Define your server details
SERVER="uitleensysteemfirda.nl"
USER="user"  # Replace with your actual username
TARGET_DIR="/tmp/admin_fix"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== UPLOADING ADMIN FIX TO PRODUCTION SERVER =====${NC}"

# Create remote directory
echo -e "${GREEN}Creating remote directory...${NC}"
ssh $USER@$SERVER "mkdir -p $TARGET_DIR"

# Upload all files
echo -e "${GREEN}Uploading files...${NC}"
scp ./* $USER@$SERVER:$TARGET_DIR/

echo -e "${GREEN}Files uploaded to $SERVER:$TARGET_DIR/${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. SSH into the server: ssh $USER@$SERVER"
echo "2. Navigate to the upload directory: cd $TARGET_DIR"
echo "3. Run the deployment script: sudo bash final_admin_fix_production.sh"
echo "4. Verify the fix: php verify_fix.php"
