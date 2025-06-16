#!/bin/bash
# Script to complete deployment of admin functionality fix to production

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== COMPLETING ADMIN FUNCTIONALITY FIX DEPLOYMENT =====${NC}"

# 1. Upload the zip file to the production server
echo -e "${GREEN}Uploading admin_fix.zip to the production server...${NC}"
scp admin_fix.zip user@uitleensysteemfirda.nl:/tmp/

if [ $? -ne 0 ]; then
    echo -e "${RED}Error uploading the file. Please check your connection and try again.${NC}"
    exit 1
fi

# 2. Execute the commands on the server
echo -e "${GREEN}Executing commands on the production server...${NC}"
ssh user@uitleensysteemfirda.nl << 'EOF'
    # Navigate to the project directory
    cd /var/www/uitleensysteemfirda.nl
    
    # Backup the original file
    cp app/Http/Controllers/UserController.php app/Http/Controllers/UserController.php.bak
    
    # Extract the files
    unzip -o /tmp/admin_fix.zip -d app/Http/Controllers/
    rm /tmp/admin_fix.zip
    
    # Clear Laravel cache
    php artisan cache:clear
    php artisan config:clear
    php artisan route:clear
    php artisan view:clear
    
    # Set proper permissions
    sudo chown -R www-data:www-data app/Http/Controllers/
    sudo chmod 644 app/Http/Controllers/UserController.php
    
    echo "Admin functionality fix deployed successfully!"
EOF

if [ $? -ne 0 ]; then
    echo -e "${RED}Error executing commands on the server. Please check the output above for details.${NC}"
    exit 1
fi

echo -e "${YELLOW}===== ADMIN FUNCTIONALITY FIX DEPLOYMENT COMPLETED =====${NC}"
echo -e "${GREEN}Now run the verification script to confirm the fix is working.${NC}"
echo -e "${GREEN}$ php verify_admin_fix.php${NC}"
