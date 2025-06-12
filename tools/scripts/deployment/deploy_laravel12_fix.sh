#!/bin/bash
# Laravel 12 Fix Deployment Script

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Server details
SERVER="92.113.19.61"
USER="u540587252"
PORT="65002"
REMOTE_PATH="/home/u540587252/domains/uitleensysteemfirda.nl/public_html"
ZIP_FILE="/home/senne/projects/uitlenen/deploy/laravel12_fix.zip"

echo -e "${YELLOW}===== DEPLOYING LARAVEL 12 FIX TO PRODUCTION =====${NC}"

# Function to execute a command on the server
remote_exec() {
    echo -e "${GREEN}Executing: $1${NC}"
    ssh -p $PORT $USER@$SERVER "$1"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Command executed successfully${NC}"
    else {
        echo -e "${RED}✗ Command failed${NC}"
        echo -e "${YELLOW}Continuing anyway...${NC}"
    }
    fi
}

# 1. Upload the fix package to the server
echo -e "${YELLOW}Uploading fix package to server...${NC}"
scp -P $PORT "$ZIP_FILE" "$USER@$SERVER:$REMOTE_PATH/laravel12_fix.zip"

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to upload the fix package. Aborting.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Fix package uploaded successfully${NC}"

# 2. Extract the package on the server
echo -e "${YELLOW}Extracting package on server...${NC}"
remote_exec "cd $REMOTE_PATH && unzip -o laravel12_fix.zip"

# 3. Run the deployment script
echo -e "${YELLOW}Running deployment script on server...${NC}"
remote_exec "cd $REMOTE_PATH/laravel12_fix && bash deploy.sh"

# 4. Clean up temporary files
echo -e "${YELLOW}Cleaning up temporary files...${NC}"
remote_exec "cd $REMOTE_PATH && rm -f laravel12_fix.zip"

echo -e "${YELLOW}===== LARAVEL 12 FIX DEPLOYMENT COMPLETED =====${NC}"
echo -e "${GREEN}Next steps:${NC}"
echo "1. Verify that the admin functionality is working properly in your application"
echo "2. If you want to remove the deployment files, run this command:"
echo "   ssh -p $PORT $USER@$SERVER \"rm -rf $REMOTE_PATH/laravel12_fix\""
echo ""
echo -e "${YELLOW}If there are any issues, backups of all modified files were created on the server${NC}"
