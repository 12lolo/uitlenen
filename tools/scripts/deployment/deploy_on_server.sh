#!/bin/bash
# Comprehensive admin fix server deployment script

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== DEPLOYING COMPREHENSIVE ADMIN FIX =====${NC}"

# Navigate to Laravel project directory
cd /var/www/uitleensysteemfirda.nl || {
    echo -e "${RED}Failed to navigate to project directory${NC}"
    exit 1
}

# Create backup
echo -e "${GREEN}Creating backups...${NC}"
mkdir -p backups/$(date +%Y%m%d)
cp -f app/Http/Controllers/UserController.php backups/$(date +%Y%m%d)/UserController.php.bak || echo -e "${YELLOW}Warning: Could not backup UserController${NC}"
cp -f routes/api.php backups/$(date +%Y%m%d)/api.php.bak || echo -e "${YELLOW}Warning: Could not backup api.php${NC}"

# Extract fix files
echo -e "${GREEN}Extracting fix files...${NC}"
mkdir -p /tmp/admin_fix
unzip -o /tmp/admin_fix_comprehensive.zip -d /tmp/admin_fix/ || {
    echo -e "${RED}Failed to extract fix files${NC}"
    exit 1
}

# Copy files
echo -e "${GREEN}Copying fixed files...${NC}"
cp -f /tmp/admin_fix/UserController.php app/Http/Controllers/ || echo -e "${RED}Failed to copy UserController${NC}"
cp -f /tmp/admin_fix/api.php routes/ || echo -e "${RED}Failed to copy api.php${NC}"
cp -f /tmp/admin_fix/comprehensive_admin_fix.php routes/ || echo -e "${RED}Failed to copy comprehensive_admin_fix.php${NC}"

# Set proper permissions
echo -e "${GREEN}Setting permissions...${NC}"
chown -R www-data:www-data app/Http/Controllers/
chown -R www-data:www-data routes/
chmod 644 app/Http/Controllers/UserController.php
chmod 644 routes/api.php
chmod 644 routes/comprehensive_admin_fix.php

# Clear Laravel cache
echo -e "${GREEN}Clearing Laravel cache...${NC}"
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Clean up
echo -e "${GREEN}Cleaning up...${NC}"
rm -rf /tmp/admin_fix
rm -f /tmp/admin_fix_comprehensive.zip

# Apply the fix
echo -e "${GREEN}Applying the fix...${NC}"
TOKEN="5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585"
RESPONSE=$(curl -s -X GET "https://uitleensysteemfirda.nl/api/comprehensive-admin-fix/fix_admin_june_2025" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")

if [[ "$RESPONSE" == *"success"* ]]; then
    echo -e "${GREEN}Fix applied successfully!${NC}"
    echo "$RESPONSE" | grep -o '"message":"[^"]*"' | cut -d'"' -f4
else
    echo -e "${RED}Failed to apply fix${NC}"
    echo "$RESPONSE"
fi

echo -e "${YELLOW}===== DEPLOYMENT COMPLETED =====${NC}"
echo -e "${GREEN}Next step: Run the verification script to confirm the fix${NC}"
