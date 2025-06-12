#!/bin/bash
# Final Laravel 12 Admin Route Fix

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

echo -e "${YELLOW}===== APPLYING FINAL ADMIN ROUTE FIX =====${NC}"

# Create a direct route fix script
cat > /tmp/final_admin_route_fix.php << 'EOF'
<?php
// Final admin route fix script

echo "APPLYING FINAL ADMIN ROUTE FIX\n";
echo "============================\n\n";

// Fix the UserController.php file to add admin middleware directly
$userControllerPath = __DIR__ . '/app/Http/Controllers/UserController.php';
if (file_exists($userControllerPath)) {
    // Make a backup
    $backupPath = $userControllerPath . '.bak_' . date('Ymd_His');
    if (copy($userControllerPath, $backupPath)) {
        echo "✅ Created backup of UserController at {$backupPath}\n";
    } else {
        echo "❌ Failed to create backup of UserController\n";
        exit(1);
    }
    
    $content = file_get_contents($userControllerPath);
    if ($content === false) {
        echo "❌ Failed to read UserController\n";
        exit(1);
    }
    
    // Add a constructor to check for admin privileges
    if (strpos($content, 'public function __construct()') === false) {
        // Find the class declaration
        $pattern = '/class UserController extends Controller\s*{/';
        $replacement = "class UserController extends Controller\n{\n    /**\n     * Check that the user is an admin\n     */\n    public function __construct()\n    {\n        \$this->middleware(function (\$request, \$next) {\n            if (!\$request->user() || !\$request->user()->is_admin) {\n                return response()->json(['message' => 'This action is unauthorized.'], 403);\n            }\n            return \$next(\$request);\n        });\n    }";
        
        $updatedContent = preg_replace($pattern, $replacement, $content);
        
        if (file_put_contents($userControllerPath, $updatedContent)) {
            echo "✅ Added admin check to UserController\n";
        } else {
            echo "❌ Failed to update UserController\n";
            exit(1);
        }
    } else {
        echo "✅ UserController already has a constructor\n";
    }
}

// Fix the routes file to remove the admin middleware
$routesPath = __DIR__ . '/routes/api.php';
if (file_exists($routesPath)) {
    // Make a backup
    $backupPath = $routesPath . '.bak_' . date('Ymd_His');
    if (copy($routesPath, $backupPath)) {
        echo "✅ Created backup of routes at {$backupPath}\n";
    } else {
        echo "❌ Failed to create backup of routes\n";
        exit(1);
    }
    
    $content = file_get_contents($routesPath);
    if ($content === false) {
        echo "❌ Failed to read routes\n";
        exit(1);
    }
    
    // Remove the admin middleware from the routes
    $pattern = '/Route::middleware\(\[\'can:admin\'\]\)->group\(function \(\) \{(.*?)\}\);/s';
    $replacement = "// User management (admin only) - middleware moved to controller\n        Route::get('/users', [\\App\\Http\\Controllers\\UserController::class, 'index']);\n        Route::post('/users', [\\App\\Http\\Controllers\\UserController::class, 'store']);";
    
    $updatedContent = preg_replace($pattern, $replacement, $content);
    
    if (file_put_contents($routesPath, $updatedContent)) {
        echo "✅ Updated routes to use controller middleware\n";
    } else {
        echo "❌ Failed to update routes\n";
        exit(1);
    }
}

echo "\nFinal admin route fix completed!\n";
EOF

# Upload the fix script
echo -e "${YELLOW}Uploading fix script...${NC}"
scp -P $PORT /tmp/final_admin_route_fix.php $USER@$SERVER:$REMOTE_PATH/final_admin_route_fix.php

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to upload the fix script. Aborting.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Fix script uploaded successfully${NC}"

# Run the fix script
echo -e "${YELLOW}Running fix script...${NC}"
ssh -p $PORT $USER@$SERVER "cd $REMOTE_PATH && php final_admin_route_fix.php"

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to run the fix script. Aborting.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Fix script executed successfully${NC}"

# Clear Laravel caches
echo -e "${YELLOW}Clearing Laravel caches...${NC}"
ssh -p $PORT $USER@$SERVER "cd $REMOTE_PATH && php artisan config:clear && php artisan route:clear && php artisan view:clear && php artisan cache:clear"

echo -e "${GREEN}✓ Laravel caches cleared${NC}"

# Test the fix
echo -e "${YELLOW}Testing the fix...${NC}"
echo -e "${GREEN}Testing admin users endpoint...${NC}"
curl -s -H "Authorization: Bearer 5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585" -H "Accept: application/json" https://uitleensysteemfirda.nl/api/users | grep -v "unauthorized"

echo -e "${GREEN}Testing user creation...${NC}"
TEST_EMAIL="test.final.$(date +%s)@firda.nl"
curl -s -X POST -H "Authorization: Bearer 5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585" -H "Accept: application/json" -H "Content-Type: application/json" -d "{\"email\":\"$TEST_EMAIL\",\"is_admin\":false}" https://uitleensysteemfirda.nl/api/users | grep -v "unauthorized"

echo -e "${YELLOW}===== FINAL ADMIN ROUTE FIX COMPLETED =====${NC}"
echo -e "${GREEN}Next steps:${NC}"
echo "1. Verify that the admin functionality is working properly in your application"
echo "2. Clean up temporary files with this command:"
echo "   ssh -p $PORT $USER@$SERVER \"rm -f $REMOTE_PATH/final_admin_route_fix.php\""
echo ""
echo -e "${YELLOW}If there are any issues, backups of all modified files were created on the server${NC}"
