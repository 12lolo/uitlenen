#!/bin/bash
# Simple production deployment script for admin fix
# by Senne - June 11, 2025

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=================================${NC}"
echo -e "${GREEN}Admin Fix Production Deployment${NC}"
echo -e "${GREEN}=================================${NC}"

# 1. Check prerequisites
echo -e "${YELLOW}Creating deployment package...${NC}"

# Create a deployment directory
mkdir -p admin_fix_deployment
mkdir -p admin_fix_deployment/app/Http/Controllers
mkdir -p admin_fix_deployment/app/Http/Middleware
mkdir -p admin_fix_deployment/routes

# Copy fixed files
cp app/Http/Controllers/UserController.php admin_fix_deployment/app/Http/Controllers/
cp app/Http/Middleware/AdminMiddleware.php admin_fix_deployment/app/Http/Middleware/
cp routes/api.php admin_fix_deployment/routes/
cp routes/admin_test_routes.php admin_fix_deployment/routes/ 2>/dev/null || echo "admin_test_routes.php not found (optional)"
cp routes/auth_check_test.php admin_fix_deployment/routes/ 2>/dev/null || echo "auth_check_test.php not found (optional)"
cp admin_api_tester.html admin_fix_deployment/ 2>/dev/null || echo "admin_api_tester.html not found (optional)"

# Create instructions
cat > admin_fix_deployment/README.txt << 'EOL'
ADMIN FIX DEPLOYMENT INSTRUCTIONS
================================

1. Back up the original files:
   - app/Http/Controllers/UserController.php
   - app/Http/Middleware/AdminMiddleware.php
   - routes/api.php

2. Copy the fixed files to your production server

3. Clear Laravel cache:
   php artisan optimize:clear
   php artisan cache:clear
   php artisan config:clear
   php artisan route:clear

4. Verify the fix:
   - Check /api/admin-health-check (should return status "ok")
   - Check /api/users with an admin token (should return user list)

================================
EOL

# Create verification script
cat > admin_fix_deployment/verify_fix.sh << 'EOL'
#!/bin/bash
# Admin fix verification script

TOKEN="$1"

if [ -z "$TOKEN" ]; then
  echo "Usage: $0 your_admin_token"
  exit 1
fi

echo "Testing admin endpoints..."
echo "1. Testing admin health check endpoint..."
curl -s https://uitleensysteemfirda.nl/api/admin-health-check

echo -e "\n\n2. Testing users endpoint with admin token..."
curl -s -H "Authorization: Bearer $TOKEN" https://uitleensysteemfirda.nl/api/users

echo -e "\n\nDone!"
EOL

chmod +x admin_fix_deployment/verify_fix.sh

# Create a post-deployment script
cat > admin_fix_deployment/post_deploy.sh << 'EOL'
#!/bin/bash
# Post deployment tasks

# Clear Laravel cache
php artisan optimize:clear
php artisan cache:clear
php artisan config:clear
php artisan route:clear

echo "Cache cleared!"
echo "Deployment complete. Please verify the fix is working."
EOL

chmod +x admin_fix_deployment/post_deploy.sh

# Create a zip file
echo -e "${YELLOW}Creating deployment zip file...${NC}"
zip -r admin_fix_deployment.zip admin_fix_deployment/

echo -e "${GREEN}=================================${NC}"
echo -e "${GREEN}Deployment package ready!${NC}"
echo -e "${GREEN}=================================${NC}"
echo ""
echo "The deployment package has been created in admin_fix_deployment.zip"
echo ""
echo "To deploy:"
echo "1. Upload admin_fix_deployment.zip to your production server"
echo "2. Unzip the file: unzip admin_fix_deployment.zip"
echo "3. Deploy the fix: cp -r admin_fix_deployment/* /path/to/your/laravel/app/"
echo "4. Run the post-deploy script: cd /path/to/your/laravel/app/ && ./post_deploy.sh"
echo "5. Verify the fix: ./verify_fix.sh your_admin_token"
echo ""
echo -e "${YELLOW}Would you like to clean up the project now? (y/n)${NC}"
read -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Running project cleanup..."
    ./cleanup_project.sh
fi
