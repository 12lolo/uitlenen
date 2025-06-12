#!/bin/bash
# Final script to fix admin middleware on production

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

echo -e "${YELLOW}===== APPLYING FINAL ADMIN MIDDLEWARE FIX =====${NC}"

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

# 1. Create a direct fixer script
echo -e "${YELLOW}Creating Laravel middleware fixer script...${NC}"

cat > /tmp/fix_laravel_middleware.php << 'EOF'
<?php
// Direct Laravel middleware fix script

// First, create a backup of the Kernel.php file
$kernelPath = __DIR__ . '/app/Http/Kernel.php';
$backupPath = $kernelPath . '.bak_' . date('Ymd_His');

echo "APPLYING LARAVEL MIDDLEWARE FIX\n";
echo "==============================\n\n";

if (!file_exists($kernelPath)) {
    echo "❌ ERROR: Kernel.php not found at {$kernelPath}\n";
    exit(1);
}

// Create a backup
if (copy($kernelPath, $backupPath)) {
    echo "✅ Created backup at {$backupPath}\n";
} else {
    echo "❌ Failed to create backup, stopping for safety\n";
    exit(1);
}

// Read the current Kernel.php
$content = file_get_contents($kernelPath);
if ($content === false) {
    echo "❌ Failed to read Kernel.php\n";
    exit(1);
}

// Step 1: Fix any duplicate entries
$pattern = "/('admin'\s*=>\s*\\\\App\\\\Http\\\\Middleware\\\\AdminMiddleware::class,)\s*'admin'\s*=>\s*\\\\App\\\\Http\\\\Middleware\\\\AdminMiddleware::class,/";
if (preg_match($pattern, $content)) {
    echo "Found duplicate 'admin' entry in routeMiddleware. Fixing...\n";
    $content = preg_replace($pattern, '$1', $content);
    echo "✅ Removed duplicate admin entry\n";
}

// Step 2: Make sure routeMiddleware exists with the correct middleware
if (!preg_match('/protected\s+\$routeMiddleware\s*=/s', $content)) {
    echo "No routeMiddleware property found. Adding it...\n";
    
    // Add before the closing brace of the class
    $lastBrace = strrpos($content, '}');
    $insert = <<<'EOT'
    
    /**
     * The application's route middleware.
     *
     * For Laravel compatibility, explicitly registering middleware.
     *
     * @var array<string, class-string|string>
     */
    protected $routeMiddleware = [
        'admin' => \App\Http\Middleware\AdminMiddleware::class,
        'check.invitation' => \App\Http\Middleware\CheckInvitationExpiry::class,
        'checkinvitation' => \App\Http\Middleware\CheckInvitationExpiry::class,
    ];

EOT;
    
    $content = substr_replace($content, $insert, $lastBrace, 0);
    echo "✅ Added routeMiddleware property\n";
} else {
    echo "✅ routeMiddleware property exists\n";
}

// Step 3: Make sure admin is defined in middlewareAliases
if (strpos($content, "'admin' => \\App\\Http\\Middleware\\AdminMiddleware::class") === false) {
    echo "Admin middleware not found in middlewareAliases, adding it...\n";
    
    // Find the middlewareAliases property
    if (preg_match('/protected\s+\$middlewareAliases\s*=\s*\[\s*([^\]]+)\s*\];/s', $content, $matches)) {
        $middlewareList = $matches[1];
        $newMiddlewareList = $middlewareList . ",\n        'admin' => \\App\\Http\\Middleware\\AdminMiddleware::class";
        $content = str_replace($middlewareList, $newMiddlewareList, $content);
        echo "✅ Added admin to middlewareAliases\n";
    } else {
        echo "❌ Could not find middlewareAliases array\n";
    }
}

// Step 4: Make sure admin middleware file exists
$adminMiddlewarePath = __DIR__ . '/app/Http/Middleware/AdminMiddleware.php';
if (!file_exists($adminMiddlewarePath)) {
    echo "Creating AdminMiddleware.php...\n";
    
    $middlewareContent = <<<'EOT'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminMiddleware
{
    /**
     * Handle an incoming request and check for admin privileges.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (!$request->user() || !$request->user()->is_admin) {
            return response()->json([
                'status' => 'error',
                'message' => 'Unauthorized. Admin privileges required.'
            ], 403);
        }

        return $next($request);
    }
}
EOT;
    
    if (file_put_contents($adminMiddlewarePath, $middlewareContent)) {
        echo "✅ Created AdminMiddleware.php\n";
    } else {
        echo "❌ Failed to create AdminMiddleware.php\n";
    }
}

// Write the updated content
if (file_put_contents($kernelPath, $content)) {
    echo "✅ Successfully updated Kernel.php\n";
} else {
    echo "❌ Failed to update Kernel.php\n";
    exit(1);
}

echo "\nMiddleware fix completed! You should now clear all Laravel caches.\n";
EOF

upload_file "/tmp/fix_laravel_middleware.php" "$REMOTE_PATH/fix_laravel_middleware.php"

# 2. Upload improved verification script
echo -e "${YELLOW}Uploading improved verification script...${NC}"
upload_file "/home/senne/projects/uitlenen/improved_verify_server_fix.php" "$REMOTE_PATH/improved_verify_server_fix.php"

# 3. Run the fixer script on the server
echo -e "${YELLOW}Running middleware fixer script...${NC}"
remote_exec "cd $REMOTE_PATH && php fix_laravel_middleware.php"

# 4. Clear all Laravel caches
echo -e "${YELLOW}Clearing Laravel caches...${NC}"
remote_exec "cd $REMOTE_PATH && php artisan config:clear"
remote_exec "cd $REMOTE_PATH && php artisan route:clear"
remote_exec "cd $REMOTE_PATH && php artisan view:clear"
remote_exec "cd $REMOTE_PATH && php artisan cache:clear"

# 5. Run the verification script
echo -e "${YELLOW}Running verification script...${NC}"
remote_exec "cd $REMOTE_PATH && php improved_verify_server_fix.php"

# 6. Create a simple test script for admin functionality
echo -e "${YELLOW}Creating admin API test script...${NC}"

cat > /tmp/quick_admin_test.php << 'EOF'
<?php
// Quick test of admin functionality

$token = "5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585"; // Replace with your admin token
$baseUrl = "https://uitleensysteemfirda.nl/api";

function testEndpoint($method, $endpoint, $data = null) {
    global $token, $baseUrl;
    
    echo "Testing $method $endpoint\n";
    
    $curl = curl_init($baseUrl . $endpoint);
    curl_setopt($curl, CURLOPT_CUSTOMREQUEST, $method);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curl, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . $token,
        'Content-Type: application/json',
        'Accept: application/json'
    ]);
    
    if ($data && ($method == 'POST' || $method == 'PUT')) {
        curl_setopt($curl, CURLOPT_POSTFIELDS, json_encode($data));
    }
    
    $response = curl_exec($curl);
    $status = curl_getinfo($curl, CURLINFO_HTTP_CODE);
    $error = curl_error($curl);
    curl_close($curl);
    
    echo "Status: $status\n";
    
    if ($error) {
        echo "Error: $error\n";
    } else {
        $data = json_decode($response, true);
        if (json_last_error() === JSON_ERROR_NONE) {
            echo "Response: " . json_encode($data, JSON_PRETTY_PRINT) . "\n";
        } else {
            echo "Response: $response\n";
        }
    }
    
    echo "\n----------------------------------\n\n";
    
    return $status;
}

echo "QUICK ADMIN FUNCTIONALITY TEST\n";
echo "============================\n\n";

// Test health check endpoint
echo "1. Testing health check endpoint:\n";
testEndpoint('GET', '/admin-health-check');

// Test direct test route
echo "2. Testing direct test route:\n";
testEndpoint('GET', '/direct-user-test');

// Test admin users route
echo "3. Testing admin users endpoint:\n";
testEndpoint('GET', '/users');

// Test simple users route
echo "4. Testing simple users endpoint:\n";
testEndpoint('GET', '/simple-users');

// Test user creation
echo "5. Testing user creation:\n";
$testEmail = 'test.' . time() . '@firda.nl';
testEndpoint('POST', '/users', [
    'email' => $testEmail,
    'is_admin' => false
]);

echo "Testing completed!\n";
EOF

upload_file "/tmp/quick_admin_test.php" "$REMOTE_PATH/quick_admin_test.php"

# 7. Run the test script
echo -e "${YELLOW}Running quick admin functionality test...${NC}"
remote_exec "cd $REMOTE_PATH && php quick_admin_test.php"

echo -e "${YELLOW}===== ADMIN MIDDLEWARE FIX COMPLETED =====${NC}"
echo -e "${GREEN}Next steps:${NC}"
echo "1. Verify that the admin functionality is working properly"
echo "2. Test the API endpoints with a valid admin token"
echo "3. Remove the temporary scripts when done with this command:"
echo "   ssh -p $PORT $USER@$SERVER \"rm $REMOTE_PATH/fix_laravel_middleware.php $REMOTE_PATH/improved_verify_server_fix.php $REMOTE_PATH/quick_admin_test.php\""
echo ""
echo -e "${YELLOW}If there are any issues, backups of all modified files were created on the server${NC}"
