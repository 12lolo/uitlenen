#!/bin/bash
# Fixed version of the admin functionality fix for production

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

echo -e "${YELLOW}===== DEPLOYING FIXED ADMIN FUNCTIONALITY =====${NC}"

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
    else {
        echo -e "${RED}✗ Command failed${NC}"
        echo -e "${YELLOW}Continuing anyway...${NC}"
    }
    fi
}

# 1. Create a backup of the current Kernel.php
echo -e "${YELLOW}Creating backup of Kernel.php...${NC}"
remote_exec "cp $REMOTE_PATH/app/Http/Kernel.php $REMOTE_PATH/app/Http/Kernel.php.bak_fixed_$(date +%Y%m%d_%H%M%S)"

# 2. Upload the fixed Kernel.php
echo -e "${YELLOW}Uploading fixed Kernel.php...${NC}"
upload_file "/home/senne/projects/uitlenen/app/Http/Kernel.php" "$REMOTE_PATH/app/Http/Kernel.php"

# 3. Create a server-side admin test script
echo -e "${YELLOW}Creating admin test script...${NC}"

cat > /tmp/test_admin_api.php << 'EOF'
<?php
// Direct admin API test script

// Set auth token here (replace with actual admin token)
$token = "5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585";
$baseUrl = "https://uitleensysteemfirda.nl/api";

// Function to make API requests
function makeRequest($method, $endpoint, $data = null) {
    global $token, $baseUrl;
    
    $url = $baseUrl . $endpoint;
    echo "Request: $method $url\n";
    
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Authorization: Bearer ' . $token
    ]);
    
    if ($data && ($method == 'POST' || $method == 'PUT')) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    }
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);
    curl_close($ch);
    
    if ($error) {
        echo "Error: $error\n";
    }
    
    echo "Status: $httpCode\n";
    
    // Parse response or return raw
    if ($response) {
        $parsed = json_decode($response, true);
        if (json_last_error() === JSON_ERROR_NONE) {
            return [
                'code' => $httpCode,
                'response' => $parsed
            ];
        }
    }
    
    return [
        'code' => $httpCode,
        'response' => $response
    ];
}

// Helper function to display test results
function printResult($name, $result) {
    echo "\n===== $name =====\n";
    echo "Status Code: " . $result['code'] . "\n";
    
    if (is_array($result['response'])) {
        echo "Response: " . json_encode($result['response'], JSON_PRETTY_PRINT) . "\n";
    } else {
        echo "Response: " . $result['response'] . "\n";
    }
    
    echo "====================\n\n";
}

echo "ADMIN API TEST\n";
echo "============\n\n";

// Test 1: Health Check
echo "Test 1: Health Check\n";
$result = makeRequest('GET', '/admin-health-check');
printResult('Health Check', $result);

// Test 2: Get Users (Admin Route)
echo "Test 2: Get Users\n";
$result = makeRequest('GET', '/users');
printResult('Get Users', $result);

// Test 3: Simple Users (Backup Admin Route)
echo "Test 3: Simple Users\n";
$result = makeRequest('GET', '/simple-users');
printResult('Simple Users', $result);

// Test 4: Create User
echo "Test 4: Create User\n";
$testEmail = "test.user." . time() . "@firda.nl";
$result = makeRequest('POST', '/users', [
    'email' => $testEmail,
    'is_admin' => false
]);
printResult('Create User', $result);

echo "Testing completed!\n";
EOF

upload_file "/tmp/test_admin_api.php" "$REMOTE_PATH/test_admin_api.php"

# 4. Create a proper fix script that will run on the server
echo -e "${YELLOW}Creating comprehensive server fix script...${NC}"

cat > /tmp/fix_kernel_middleware.php << 'EOF'
<?php
// Direct server fix for Kernel.php

// File path
$kernelPath = __DIR__ . '/app/Http/Kernel.php';

echo "FIXING KERNEL MIDDLEWARE REGISTRATION\n";
echo "==================================\n\n";

// Backup the file
$backupPath = $kernelPath . '.bak_' . date('Ymd_His');
if (copy($kernelPath, $backupPath)) {
    echo "✅ Created backup at $backupPath\n";
} else {
    echo "❌ Failed to create backup\n";
    exit(1);
}

// Read the file
$content = file_get_contents($kernelPath);
if ($content === false) {
    echo "❌ Failed to read Kernel.php\n";
    exit(1);
}

// Check for duplicate entry in routeMiddleware
$pattern = "/('admin'\s*=>\s*\\\\App\\\\Http\\\\Middleware\\\\AdminMiddleware::class,)\s*'admin'\s*=>\s*\\\\App\\\\Http\\\\Middleware\\\\AdminMiddleware::class,/";
if (preg_match($pattern, $content)) {
    echo "Found duplicate 'admin' entry in routeMiddleware. Fixing...\n";
    $content = preg_replace($pattern, '$1', $content);
}

// Check if routeMiddleware property exists
if (!preg_match('/protected\s+\$routeMiddleware\s*=/s', $content)) {
    echo "No routeMiddleware property found. Adding it...\n";
    
    // Add routeMiddleware property before the last closing brace
    $routeMiddlewareCode = <<<'CODE'
    
    /**
     * The application's route middleware.
     *
     * These middleware may be assigned to groups or used individually.
     *
     * @var array<string, class-string|string>
     */
    protected $routeMiddleware = [
        'admin' => \App\Http\Middleware\AdminMiddleware::class,
        'check.invitation' => \App\Http\Middleware\CheckInvitationExpiry::class,
        'checkinvitation' => \App\Http\Middleware\CheckInvitationExpiry::class,
    ];
CODE;
    
    $lastBracePos = strrpos($content, '}');
    $content = substr_replace($content, $routeMiddlewareCode, $lastBracePos, 0);
    echo "✅ Added routeMiddleware property\n";
} else {
    echo "✅ routeMiddleware property exists\n";
    
    // Make sure admin middleware is included in routeMiddleware
    if (strpos($content, "'admin' => \\App\\Http\\Middleware\\AdminMiddleware::class") === false) {
        echo "Adding admin middleware to routeMiddleware...\n";
        
        // Add to existing routeMiddleware
        $content = preg_replace(
            '/(protected\s+\$routeMiddleware\s*=\s*\[)/',
            "$1\n        'admin' => \\App\\Http\\Middleware\\AdminMiddleware::class,",
            $content
        );
        echo "✅ Added admin middleware to routeMiddleware\n";
    } else {
        echo "✅ Admin middleware is included in routeMiddleware\n";
    }
}

// Write the updated content back to the file
if (file_put_contents($kernelPath, $content)) {
    echo "✅ Successfully updated Kernel.php\n";
} else {
    echo "❌ Failed to write updated content to Kernel.php\n";
    exit(1);
}

echo "\nKernel.php has been fixed. Please clear all Laravel caches.\n";
EOF

upload_file "/tmp/fix_kernel_middleware.php" "$REMOTE_PATH/fix_kernel_middleware.php"

# 5. Run the fix script on the server
echo -e "${YELLOW}Running fix script on the server...${NC}"
remote_exec "cd $REMOTE_PATH && php fix_kernel_middleware.php"

# 6. Clear all Laravel caches
echo -e "${YELLOW}Clearing Laravel caches...${NC}"
remote_exec "cd $REMOTE_PATH && php artisan cache:clear"
remote_exec "cd $REMOTE_PATH && php artisan config:clear"
remote_exec "cd $REMOTE_PATH && php artisan route:clear"
remote_exec "cd $REMOTE_PATH && php artisan view:clear"

# 7. Run the verification script
echo -e "${YELLOW}Running verification script...${NC}"
remote_exec "cd $REMOTE_PATH && php verify_server_fix.php"

# 8. Run the admin API test
echo -e "${YELLOW}Testing admin API endpoints...${NC}"
remote_exec "cd $REMOTE_PATH && php test_admin_api.php"

echo -e "${YELLOW}===== FINAL ADMIN FIX DEPLOYMENT COMPLETED =====${NC}"
echo -e "${GREEN}Next steps:${NC}"
echo "1. Verify the admin API test results above"
echo "2. Check the logs for any remaining errors"
echo "3. Remove temporary scripts when done with the following command:"
echo "   ssh -p $PORT $USER@$SERVER \"rm $REMOTE_PATH/fix_kernel_middleware.php $REMOTE_PATH/test_admin_api.php $REMOTE_PATH/verify_server_fix.php\""
echo ""
echo -e "${YELLOW}If there are any issues, backups of Kernel.php were created on the server${NC}"
