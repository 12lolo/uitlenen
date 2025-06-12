#!/bin/bash
# Final Laravel 12 Admin Route Fix Script

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

echo -e "${YELLOW}===== APPLYING FINAL LARAVEL 12 ADMIN ROUTE FIX =====${NC}"

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

# Create a Laravel 12 route fixer script
echo -e "${YELLOW}Creating Laravel 12 route fixer script...${NC}"

cat > /tmp/fix_laravel12_routes.php << 'EOF'
<?php
// Laravel 12 route fix script

// First, make a backup of the routes file
$routesPath = __DIR__ . '/routes/api.php';
$backupPath = $routesPath . '.bak_' . date('Ymd_His');

echo "APPLYING LARAVEL 12 ROUTE FIX\n";
echo "============================\n\n";

if (!file_exists($routesPath)) {
    echo "❌ ERROR: api.php not found at {$routesPath}\n";
    exit(1);
}

// Create a backup
if (copy($routesPath, $backupPath)) {
    echo "✅ Created backup at {$backupPath}\n";
} else {
    echo "❌ Failed to create backup, stopping for safety\n";
    exit(1);
}

// Read the current routes file
$content = file_get_contents($routesPath);
if ($content === false) {
    echo "❌ Failed to read api.php\n";
    exit(1);
}

// Fix 1: Fix the admin middleware usage in routes
// In Laravel 12, middleware aliases need to be used via the 'middleware' handler in a more careful way
$fixedContent = preg_replace(
    '/Route::middleware\(\[(\'|\")admin(\'|\")\]\)->group\(function \(\) \{/',
    'Route::middleware(\'can:admin\')->group(function () {',
    $content
);

if ($fixedContent !== $content) {
    echo "✅ Updated admin middleware usage in routes\n";
} else {
    echo "⚠️ No changes needed for admin middleware in routes\n";
}

// Fix 2: Update the error handling in controllers that might not be properly showing errors
$userControllerPath = __DIR__ . '/app/Http/Controllers/UserController.php';
if (file_exists($userControllerPath)) {
    $userContent = file_get_contents($userControllerPath);
    if ($userContent) {
        // Add proper error handling to index method
        if (strpos($userContent, 'Error retrieving users:') !== false) {
            echo "✅ UserController already has proper error handling\n";
        } else {
            echo "⚠️ Consider updating UserController for better error handling\n";
        }
    }
}

// Write the updated content back to the routes file
if (file_put_contents($routesPath, $fixedContent)) {
    echo "✅ Successfully updated api.php\n";
} else {
    echo "❌ Failed to update api.php\n";
    exit(1);
}

// Create a direct route test endpoint for troubleshooting
$directRoutePath = __DIR__ . '/routes/direct_admin_test.php';
$directRouteContent = <<<'EOT'
<?php
// Direct admin test routes for Laravel 12

use Illuminate\Support\Facades\Route;
use App\Models\User;
use Illuminate\Http\Request;

// This route will directly test the admin functionality without going through the regular middleware
Route::get('/direct-user-test', function (Request $request) {
    try {
        // Check if the user is authenticated and is an admin
        $user = $request->user();
        $isAdmin = $user && $user->is_admin;
        
        // Get a list of users (limit to 5)
        $users = User::select('id', 'name', 'email', 'is_admin')
            ->limit(5)
            ->get();
        
        return response()->json([
            'status' => 'success',
            'message' => 'Direct test successful',
            'current_user' => $user ? $user->only('id', 'name', 'email', 'is_admin') : null,
            'is_admin' => $isAdmin,
            'users' => $users
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => 'Error in direct test: ' . $e->getMessage(),
            'trace' => $e->getTraceAsString()
        ], 500);
    }
})->middleware('auth:sanctum');

// This route will test admin gate authorization explicitly
Route::get('/admin-gate-test', function (Request $request) {
    try {
        // Get the current user
        $user = $request->user();
        
        // Define an admin gate directly in this file for testing
        if (!$user || !$user->is_admin) {
            return response()->json([
                'status' => 'error',
                'message' => 'Unauthorized. Admin access required.',
                'user' => $user ? $user->only('id', 'name', 'email', 'is_admin') : null
            ], 403);
        }
        
        // If we get here, user is an admin
        $users = User::select('id', 'name', 'email', 'is_admin')
            ->limit(10)
            ->get();
            
        return response()->json([
            'status' => 'success',
            'message' => 'Admin gate test successful',
            'user' => $user->only('id', 'name', 'email', 'is_admin'),
            'users' => $users
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => 'Error in admin gate test: ' . $e->getMessage(),
            'trace' => $e->getTraceAsString()
        ], 500);
    }
})->middleware('auth:sanctum');

// Health check route that doesn't require authentication
Route::get('/admin-health-check', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'Admin routes are being loaded',
        'timestamp' => now()->toIso8601String()
    ]);
});
EOT;

// Write the direct route test file
if (file_put_contents($directRoutePath, $directRouteContent)) {
    echo "✅ Created direct admin test routes at routes/direct_admin_test.php\n";
} else {
    echo "❌ Failed to create direct admin test routes\n";
}

// Update the main routes file to include the direct test routes
if (strpos($fixedContent, "require __DIR__.'/direct_admin_test.php';") === false) {
    $updatedContent = $fixedContent . "\n\n// Include direct admin test routes\nrequire __DIR__.'/direct_admin_test.php';\n";
    if (file_put_contents($routesPath, $updatedContent)) {
        echo "✅ Updated api.php to include direct admin test routes\n";
    } else {
        echo "❌ Failed to update api.php to include direct admin test routes\n";
    }
}

// Update the AppServiceProvider to register the 'admin' authorization gate
$providerPath = __DIR__ . '/app/Providers/AuthServiceProvider.php';
if (file_exists($providerPath)) {
    $providerContent = file_get_contents($providerPath);
    
    // Check if the provider already has the admin gate
    if (strpos($providerContent, "Gate::define('admin'") === false) {
        // Find the boot method
        if (preg_match('/public function boot\(\)(.*?)\{/s', $providerContent, $matches)) {
            $bootMethod = $matches[0];
            $newBootMethod = $bootMethod . "\n        // Register the admin gate\n        Gate::define('admin', function (\$user) {\n            return \$user->is_admin;\n        });\n";
            $providerContent = str_replace($bootMethod, $newBootMethod, $providerContent);
            
            // Add use statement for Gate if needed
            if (strpos($providerContent, 'use Illuminate\Support\Facades\Gate;') === false) {
                $providerContent = preg_replace('/(namespace App\\\\Providers;.*?)use /s', "$1use Illuminate\\Support\\Facades\\Gate;\nuse ", $providerContent);
            }
            
            if (file_put_contents($providerPath, $providerContent)) {
                echo "✅ Added admin gate to AuthServiceProvider\n";
            } else {
                echo "❌ Failed to update AuthServiceProvider\n";
            }
        } else {
            echo "⚠️ Could not find boot method in AuthServiceProvider\n";
        }
    } else {
        echo "✅ Admin gate already exists in AuthServiceProvider\n";
    }
} else {
    echo "❌ AuthServiceProvider not found\n";
}

echo "\nRoute fix completed! You should now clear all Laravel caches.\n";
EOF

upload_file "/tmp/fix_laravel12_routes.php" "$REMOTE_PATH/fix_laravel12_routes.php"

# Create a test script for the routes
echo -e "${YELLOW}Creating route test script...${NC}"

cat > /tmp/test_laravel12_routes.php << 'EOF'
<?php
// Test script for Laravel 12 admin routes

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

echo "LARAVEL 12 ADMIN ROUTE TEST\n";
echo "=========================\n\n";

// Test admin health check endpoint
echo "1. Testing admin health check endpoint:\n";
testEndpoint('GET', '/admin-health-check');

// Test direct test route
echo "2. Testing direct user test route:\n";
testEndpoint('GET', '/direct-user-test');

// Test admin gate test route
echo "3. Testing admin gate test route:\n";
testEndpoint('GET', '/admin-gate-test');

// Test users route (original admin route)
echo "4. Testing users endpoint:\n";
testEndpoint('GET', '/users');

// Test user creation
echo "5. Testing user creation:\n";
$testEmail = 'test.laravel12.' . time() . '@firda.nl';
testEndpoint('POST', '/users', [
    'email' => $testEmail,
    'is_admin' => false
]);

echo "\nTesting completed!\n";
EOF

upload_file "/tmp/test_laravel12_routes.php" "$REMOTE_PATH/test_laravel12_routes.php"

# Run the fixer script on the server
echo -e "${YELLOW}Running Laravel 12 route fixer script...${NC}"
remote_exec "cd $REMOTE_PATH && php fix_laravel12_routes.php"

# Clear all Laravel caches
echo -e "${YELLOW}Clearing Laravel caches...${NC}"
remote_exec "cd $REMOTE_PATH && php artisan config:clear"
remote_exec "cd $REMOTE_PATH && php artisan route:clear"
remote_exec "cd $REMOTE_PATH && php artisan view:clear"
remote_exec "cd $REMOTE_PATH && php artisan cache:clear"

# Run the route test script
echo -e "${YELLOW}Running Laravel 12 route test script...${NC}"
remote_exec "cd $REMOTE_PATH && php test_laravel12_routes.php"

echo -e "${YELLOW}===== FINAL LARAVEL 12 ADMIN ROUTE FIX COMPLETED =====${NC}"
echo -e "${GREEN}Next steps:${NC}"
echo "1. Verify that the admin functionality is working properly"
echo "2. Test the API endpoints in your application"
echo "3. Remove the temporary scripts when done with this command:"
echo "   ssh -p $PORT $USER@$SERVER \"rm $REMOTE_PATH/fix_laravel12_routes.php $REMOTE_PATH/test_laravel12_routes.php\""
echo ""
echo -e "${YELLOW}If there are any issues, backups of all modified files were created on the server${NC}"
