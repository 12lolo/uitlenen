#!/bin/bash
# Deploy the admin fix to production

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

# 1. Create a backup of the current Kernel.php
echo -e "${YELLOW}Creating backup of Kernel.php...${NC}"
remote_exec "cp $REMOTE_PATH/app/Http/Kernel.php $REMOTE_PATH/app/Http/Kernel.php.bak_$(date +%Y%m%d_%H%M%S)"

# 2. Upload the updated Kernel.php
echo -e "${YELLOW}Uploading updated Kernel.php...${NC}"
upload_file "/home/senne/projects/uitlenen/app/Http/Kernel.php" "$REMOTE_PATH/app/Http/Kernel.php"

# 3. Create a server-side fix verification script
echo -e "${YELLOW}Creating server-side fix verification script...${NC}"

cat > /tmp/verify_server_fix.php << 'EOF'
<?php
// Server-side verification script for admin fix

echo "SERVER-SIDE ADMIN FIX VERIFICATION\n";
echo "===============================\n\n";

// 1. Check Kernel.php
echo "1. Checking Kernel.php for routeMiddleware:\n";
$kernelPath = __DIR__ . '/app/Http/Kernel.php';
if (file_exists($kernelPath)) {
    $kernelContent = file_get_contents($kernelPath);
    
    // Check for routeMiddleware
    if (preg_match('/protected\s+\$routeMiddleware\s*=/s', $kernelContent)) {
        echo "✅ routeMiddleware property found\n";
        
        // Check for admin middleware
        if (strpos($kernelContent, "'admin' => \\App\\Http\\Middleware\\AdminMiddleware::class") !== false) {
            echo "✅ Admin middleware is properly registered\n";
        } else {
            echo "❌ Admin middleware not found in routeMiddleware\n";
        }
    } else {
        echo "❌ routeMiddleware property not found\n";
    }
} else {
    echo "❌ Kernel.php file not found\n";
}

// 2. Check AdminMiddleware
echo "\n2. Checking AdminMiddleware:\n";
$middlewarePath = __DIR__ . '/app/Http/Middleware/AdminMiddleware.php';
if (file_exists($middlewarePath)) {
    echo "✅ AdminMiddleware.php exists\n";
} else {
    echo "❌ AdminMiddleware.php not found\n";
}

// 3. Check routes
echo "\n3. Checking API routes:\n";
$routesPath = __DIR__ . '/routes/api.php';
if (file_exists($routesPath)) {
    $routesContent = file_get_contents($routesPath);
    
    // Check for array middleware syntax
    if (strpos($routesContent, "middleware(['admin'])") !== false) {
        echo "✅ Routes using correct array middleware syntax\n";
    } else if (strpos($routesContent, "middleware('admin')") !== false) {
        echo "❌ Routes using string middleware syntax\n";
    } else {
        echo "❓ No admin middleware found in routes\n";
    }
} else {
    echo "❌ api.php file not found\n";
}

// 4. Check if the fix was successful
echo "\n4. Testing route registration:\n";
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$kernel = app(\Illuminate\Contracts\Http\Kernel::class);
$routeMiddleware = $kernel->getRouteMiddleware();

if (isset($routeMiddleware['admin'])) {
    echo "✅ 'admin' middleware is registered in the application\n";
} else {
    echo "❌ 'admin' middleware is NOT registered in the application\n";
}

echo "\nVerification completed!\n";
EOF

upload_file "/tmp/verify_server_fix.php" "$REMOTE_PATH/verify_server_fix.php"

# 4. Clear all Laravel caches on the server
echo -e "${YELLOW}Clearing Laravel caches...${NC}"
remote_exec "cd $REMOTE_PATH && php artisan cache:clear && php artisan config:clear && php artisan route:clear && php artisan view:clear"

# 5. Run the verification script
echo -e "${YELLOW}Running verification script...${NC}"
remote_exec "cd $REMOTE_PATH && php verify_server_fix.php"

echo -e "${YELLOW}===== ADMIN FIX DEPLOYMENT COMPLETED =====${NC}"
echo -e "${GREEN}Next steps:${NC}"
echo "1. Test the admin endpoints with a valid admin token"
echo "2. Check the logs for any remaining errors"
echo "3. Remove temporary verification files when done"
echo ""
echo -e "${YELLOW}If there are any issues, a backup of Kernel.php was created on the server${NC}"
