#!/bin/bash
# Deploy the FINAL admin fix to production

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Server details
SERVER="92.113.19.61"
PORT="65002"
USER="u540587252"
REMOTE_PATH="/home/u540587252/domains/uitleensysteemfirda.nl/public_html"

echo -e "${YELLOW}===== DEPLOYING FINAL ADMIN FIX TO PRODUCTION =====${NC}"

# Function to upload a file
upload_file() {
    local src="$1"
    local dest="$2"
    echo -e "${GREEN}Uploading $src to $dest${NC}"
    scp -P $PORT "$src" "$USER@$SERVER:$dest"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ File uploaded successfully${NC}"
    else
        echo -e "${RED}✗ Failed to upload file${NC}"
        exit 1
    fi
}

# Function to execute a command on the server
remote_exec() {
    echo -e "${GREEN}Executing: $1${NC}"
    ssh -p $PORT $USER@$SERVER "$1"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Command executed successfully${NC}"
    else
        echo -e "${RED}✗ Command failed${NC}"
        exit 1
    fi
}

# 1. Upload the updated UserController without password display
echo -e "${YELLOW}Uploading updated UserController...${NC}"
upload_file "/home/senne/projects/uitlenen/app/Http/Controllers/UserController.php" "$REMOTE_PATH/app/Http/Controllers/UserController.php"

# 2. Upload the cleanup script
echo -e "${YELLOW}Uploading cleanup script...${NC}"
upload_file "/home/senne/projects/uitlenen/cleanup_production.sh" "$REMOTE_PATH/cleanup_production.sh"

# 3. Upload the verification script
echo -e "${YELLOW}Uploading verification script...${NC}"
upload_file "/home/senne/projects/uitlenen/verify_admin_functionality.sh" "$REMOTE_PATH/verify_admin_functionality.sh"

# 4. Make scripts executable
echo -e "${YELLOW}Making scripts executable...${NC}"
remote_exec "cd $REMOTE_PATH && chmod +x cleanup_production.sh verify_admin_functionality.sh"

# 5. Run the cleanup script
echo -e "${YELLOW}Running cleanup script...${NC}"
remote_exec "cd $REMOTE_PATH && ./cleanup_production.sh"

echo -e "${YELLOW}===== FINAL ADMIN FIX DEPLOYMENT COMPLETED =====${NC}"
echo -e "${GREEN}Next steps:${NC}"
echo "1. Verify the admin functionality by running:"
echo -e "   ${YELLOW}ssh -p $PORT $USER@$SERVER${NC}"
echo -e "   ${YELLOW}cd $REMOTE_PATH${NC}"
echo -e "   ${YELLOW}./verify_admin_functionality.sh${NC}"
echo ""
echo "2. The following changes have been made:"
echo "   - Removed temporary password display from UserController"
echo "   - Executed comprehensive cleanup script"
echo "   - Cleared all Laravel caches"
echo ""
echo -e "${GREEN}The admin functionality should now be working correctly and securely.${NC}"
