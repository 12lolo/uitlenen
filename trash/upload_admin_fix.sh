#!/bin/bash
# Script to upload and apply admin fix to production server

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

echo -e "${YELLOW}===== UPLOADING ADMIN FIX TO PRODUCTION SERVER =====${NC}"

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

# 1. Create necessary directories on the server
echo -e "${YELLOW}Creating directories on the server...${NC}"
remote_exec "mkdir -p $REMOTE_PATH/backups/admin_fix_$(date +%Y%m%d)"

# 2. Backup existing files
echo -e "${YELLOW}Creating backups on the server...${NC}"
remote_exec "cp $REMOTE_PATH/app/Http/Controllers/UserController.php $REMOTE_PATH/backups/admin_fix_$(date +%Y%m%d)/UserController.php.bak"
remote_exec "cp $REMOTE_PATH/routes/api.php $REMOTE_PATH/backups/admin_fix_$(date +%Y%m%d)/api.php.bak"

# 3. Upload the fixed UserController
echo -e "${YELLOW}Uploading fixed UserController...${NC}"
upload_file "/home/senne/projects/uitlenen/app/Http/Controllers/UserController.php" "$REMOTE_PATH/app/Http/Controllers/UserController.php"

# 4. Upload the SimpleUserController
echo -e "${YELLOW}Uploading SimpleUserController...${NC}"
upload_file "/home/senne/projects/uitlenen/app/Http/Controllers/SimpleUserController.php" "$REMOTE_PATH/app/Http/Controllers/SimpleUserController.php"

# 5. Upload the health check routes
echo -e "${YELLOW}Creating health check routes file...${NC}"
cat > /tmp/admin_health_check.php << 'EOF'
<?php
// Admin health check routes

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;

// Add a health check route that doesn't require authentication
Route::get('/admin-health-check', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'Admin routes are being loaded',
        'timestamp' => now()->toIso8601String()
    ]);
});

// Direct test route without admin middleware
Route::get('/direct-user-test', function (Request $request) {
    try {
        $users = \App\Models\User::select('id', 'name', 'email', 'is_admin')
            ->limit(5)
            ->get();
            
        return response()->json([
            'status' => 'success',
            'message' => 'Direct test successful',
            'current_user' => $request->user() ? $request->user()->only('id', 'name', 'email', 'is_admin') : null,
            'users' => $users
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => $e->getMessage(),
            'trace' => $e->getTraceAsString()
        ], 500);
    }
})->middleware('auth:sanctum');
EOF
upload_file "/tmp/admin_health_check.php" "$REMOTE_PATH/routes/admin_health_check.php"

# 6. Fix the routes file
echo -e "${YELLOW}Fixing routes file...${NC}"
remote_exec "sed -i 's/Route::middleware(\"admin\")/Route::middleware([\"admin\"])/g' $REMOTE_PATH/routes/api.php"
remote_exec "if ! grep -q 'admin_health_check.php' $REMOTE_PATH/routes/api.php; then echo -e \"\n// Include the admin health check routes\nrequire __DIR__.'/admin_health_check.php';\" >> $REMOTE_PATH/routes/api.php; fi"

# 7. Clear Laravel cache
echo -e "${YELLOW}Clearing Laravel cache...${NC}"
remote_exec "cd $REMOTE_PATH && php artisan cache:clear && php artisan config:clear && php artisan route:clear && php artisan view:clear"

# 8. Create verification script
echo -e "${YELLOW}Creating verification script...${NC}"
cat > /tmp/verify_admin_fix.php << 'EOF'
<?php
// Verify admin functionality fix on production

$token = "5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585"; // Replace with your admin token
$baseUrl = "https://uitleensysteemfirda.nl/api";

function makeRequest($method, $endpoint, $data = null) {
    global $token, $baseUrl;
    
    $ch = curl_init($baseUrl . $endpoint);
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
    curl_close($ch);
    
    return [
        'code' => $httpCode,
        'response' => json_decode($response, true)
    ];
}

echo "===== VERIFYING ADMIN FIX ON PRODUCTION =====\n\n";

// 0. Test health check endpoint (doesn't require auth)
echo "0. Testing health check endpoint...\n";
$result = makeRequest('GET', '/admin-health-check');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Admin routes are being loaded correctly.\n\n";
} else {
    echo "❌ Admin routes might not be loaded correctly.\n\n";
}

// 1. Test direct route with auth
echo "1. Testing direct user test endpoint...\n";
$result = makeRequest('GET', '/direct-user-test');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Direct test route is working.\n";
    echo "Current user: " . json_encode($result['response']['current_user'] ?? 'Not available') . "\n";
    echo "Users: " . count($result['response']['users'] ?? []) . " found\n\n";
} else {
    echo "❌ Direct test route failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

// 2. Test regular admin route
echo "2. Testing regular admin route (GET /users)...\n";
$result = makeRequest('GET', '/users');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Regular admin route is working.\n";
    echo "Users found: " . count($result['response'] ?? []) . "\n\n";
} else {
    echo "❌ Regular admin route failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

// 3. Test simple admin route
echo "3. Testing simple admin route (GET /simple-users)...\n";
$result = makeRequest('GET', '/simple-users');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Simple admin route is working.\n";
    echo "Users found: " . count($result['response']['users'] ?? []) . "\n\n";
} else {
    echo "❌ Simple admin route failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

// 4. Test user creation
$testEmail = "test" . time() . "@firda.nl";
echo "4. Testing user creation (POST /users with email: $testEmail)...\n";
$result = makeRequest('POST', '/users', [
    'email' => $testEmail,
    'is_admin' => false
]);
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 201) {
    echo "✅ User creation is working.\n";
    echo "User ID: " . ($result['response']['user']['id'] ?? 'Not available') . "\n";
    echo "Temp password: " . ($result['response']['temp_password'] ?? 'Not provided') . "\n\n";
} else {
    echo "❌ User creation failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

echo "===== VERIFICATION COMPLETED =====\n";
EOF
upload_file "/tmp/verify_admin_fix.php" "$REMOTE_PATH/verify_admin_fix.php"

echo -e "${YELLOW}===== ADMIN FIX DEPLOYED TO PRODUCTION =====${NC}"
echo -e "${GREEN}Next steps:${NC}"
echo "1. Verify the fix: php $REMOTE_PATH/verify_admin_fix.php"
echo "2. Check the logs: tail -f $REMOTE_PATH/storage/logs/laravel-*.log"
echo "3. Test the admin endpoints with a valid admin token"
echo ""
echo -e "${YELLOW}If there are any issues, backups were created in $REMOTE_PATH/backups/admin_fix_$(date +%Y%m%d)/${NC}"
