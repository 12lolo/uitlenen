#!/bin/bash
# Laravel 12 Fix Deployment Script

# Ensure we're in the right directory
cd "$(dirname "$0")"

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== DEPLOYING LARAVEL 12 ADMIN FIX =====${NC}"

# 1. Fix routes
echo -e "${GREEN}Fixing routes...${NC}"
php fix_routes.php

# 2. Copy AuthServiceProvider
echo -e "${GREEN}Installing AuthServiceProvider...${NC}"
mkdir -p app/Providers
cp -f app/Providers/AuthServiceProvider.php app/Providers/

# 3. Clear Laravel caches
echo -e "${GREEN}Clearing Laravel caches...${NC}"
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear

# 4. Test the fix
echo -e "${GREEN}Testing the fix...${NC}"
php test_admin.php

echo -e "${YELLOW}===== DEPLOYMENT COMPLETED =====${NC}"
echo -e "${GREEN}Next steps:${NC}"
echo "1. Verify that the admin functionality is working properly in your application"
echo "2. If any issues remain, check the detailed test output above"
echo ""
echo -e "${YELLOW}Note: If there are any issues, backups of all modified files were created${NC}"
