#!/bin/bash
# Final Admin Fix Deployment Script
# Date: June 11, 2025

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Laravel 12 Admin Fix - Final Deployment${NC}"
echo -e "${GREEN}Date: $(date)${NC}"
echo -e "${GREEN}=========================================${NC}"

TOKEN="$1"

if [ -z "$TOKEN" ]; then
  echo -e "${YELLOW}No admin token provided. Will only deploy fixes without testing.${NC}"
  echo -e "For full deployment with testing: $0 your_admin_token"
  echo ""
fi

echo -e "${YELLOW}1. Creating deployment directory...${NC}"
DEPLOY_DIR="admin_fix_final"
mkdir -p $DEPLOY_DIR

# Copy essential fix files
echo -e "${YELLOW}2. Copying essential files...${NC}"
mkdir -p $DEPLOY_DIR/app/Http/Controllers
mkdir -p $DEPLOY_DIR/app/Http/Middleware
mkdir -p $DEPLOY_DIR/routes
mkdir -p $DEPLOY_DIR/public

# Copy controllers and middlewares
cp app/Http/Controllers/UserController.php $DEPLOY_DIR/app/Http/Controllers/
cp app/Http/Middleware/AdminMiddleware.php $DEPLOY_DIR/app/Http/Middleware/ 
cp routes/api.php $DEPLOY_DIR/routes/

# Copy other necessary files
if [ -f "routes/admin_test_routes.php" ]; then
  cp routes/admin_test_routes.php $DEPLOY_DIR/routes/
fi
if [ -f "routes/auth_check_test.php" ]; then
  cp routes/auth_check_test.php $DEPLOY_DIR/routes/
fi
if [ -f "admin_api_tester.html" ]; then
  cp admin_api_tester.html $DEPLOY_DIR/public/
fi

# Create instruction file
echo -e "${YELLOW}3. Creating deployment instructions...${NC}"
cat > $DEPLOY_DIR/DEPLOY_INSTRUCTIONS.md << 'EOL'
# Laravel 12 Admin Fix Deployment Instructions

## Overview
This package fixes the 500 Internal Server Error occurring in the admin functionality, specifically related to Laravel 12 middleware resolution and administrator authorization issues.

## Deployment Steps

### 1. Backup Files
First, backup these files on your production server:
```bash
cp app/Http/Controllers/UserController.php app/Http/Controllers/UserController.php.bak
cp app/Http/Middleware/AdminMiddleware.php app/Http/Middleware/AdminMiddleware.php.bak
cp routes/api.php routes/api.php.bak
```

### 2. Deploy Files
Copy the files from this package to your Laravel installation:
```bash
cp -R * /path/to/your/laravel/app/
```

### 3. Clear Laravel Cache
```bash
cd /path/to/your/laravel/app
php artisan optimize:clear
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

### 4. Verify Deployment
Check that the following endpoints work:
- `GET /api/admin-health-check` - Should return a 200 OK
- `GET /api/users` (with admin token) - Should return a list of users

## Troubleshooting
If you encounter issues:
1. Check the Laravel logs: `tail -f storage/logs/laravel*.log`
2. Make sure the right files were copied
3. Ensure the Laravel cache was cleared properly

## Rollback
In case of problems, restore the backup files:
```bash
cp app/Http/Controllers/UserController.php.bak app/Http/Controllers/UserController.php
cp app/Http/Middleware/AdminMiddleware.php.bak app/Http/Middleware/AdminMiddleware.php
cp routes/api.php.bak routes/api.php
```
EOL

# Create verification script
echo -e "${YELLOW}4. Creating verification script...${NC}"
cat > $DEPLOY_DIR/verify_deployment.sh << 'EOL'
#!/bin/bash
# Admin fix verification script

TOKEN="$1"
BASE_URL="$2"

if [ -z "$TOKEN" ]; then
  echo "Usage: $0 your_admin_token [base_url]"
  echo "Example: $0 13|6IQsPIAL9R9cFaf0... https://yourdomain.com/api"
  exit 1
fi

if [ -z "$BASE_URL" ]; then
  BASE_URL="https://uitleensysteemfirda.nl/api"
fi

echo "Testing admin endpoints at $BASE_URL..."
echo "1. Testing admin health check endpoint..."
curl -s $BASE_URL/admin-health-check

echo -e "\n\n2. Testing users endpoint with admin token..."
curl -s -H "Authorization: Bearer $TOKEN" $BASE_URL/users

echo -e "\n\nDone!"
EOL

chmod +x $DEPLOY_DIR/verify_deployment.sh

# Create post-deployment script
echo -e "${YELLOW}5. Creating post-deployment script...${NC}"
cat > $DEPLOY_DIR/post_deploy.sh << 'EOL'
#!/bin/bash
# Post-deployment tasks

# Clear Laravel cache
php artisan optimize:clear
php artisan cache:clear
php artisan config:clear
php artisan route:clear

echo "Cache cleared successfully."
echo "Deployment complete - please run the verification script next."
EOL

chmod +x $DEPLOY_DIR/post_deploy.sh

# Create deployment package
echo -e "${YELLOW}6. Creating deployment ZIP package...${NC}"
zip -r admin_fix_final_deployment.zip $DEPLOY_DIR/*

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Deployment Package Ready!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Files are in $DEPLOY_DIR/"
echo "ZIP package: admin_fix_final_deployment.zip"
echo ""
echo "To deploy to production:"
echo "1. Upload admin_fix_final_deployment.zip to your server"
echo "2. Unzip the package: unzip admin_fix_final_deployment.zip"
echo "3. Follow the instructions in DEPLOY_INSTRUCTIONS.md"
echo -e "${GREEN}=========================================${NC}"

# Test deployment if token was provided
if [ -n "$TOKEN" ]; then
  echo -e "${YELLOW}\nTesting current production with your token...${NC}"
  
  echo "Testing admin health check endpoint..."
  curl -s https://uitleensysteemfirda.nl/api/admin-health-check
  
  echo -e "\n\nTesting users endpoint..."
  curl -s -H "Authorization: Bearer $TOKEN" https://uitleensysteemfirda.nl/api/users
  
  echo -e "\n\nDone testing current production!"
fi
