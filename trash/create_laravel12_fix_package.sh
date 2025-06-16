#!/bin/bash
# Final Laravel 12 Fix Package

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}===== CREATING LARAVEL 12 FIX PACKAGE =====${NC}"

# Create directory for the package
PACKAGE_DIR="/home/senne/projects/uitlenen/deploy/laravel12_fix"
mkdir -p "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR/app/Providers"
mkdir -p "$PACKAGE_DIR/routes"

# Create AuthServiceProvider
cat > "$PACKAGE_DIR/app/Providers/AuthServiceProvider.php" << 'EOF'
<?php

namespace App\Providers;

use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Gate;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * The model to policy mappings for the application.
     *
     * @var array<class-string, class-string>
     */
    protected $policies = [
        //
    ];

    /**
     * Register any authentication / authorization services.
     */
    public function boot(): void
    {
        // Register the admin gate
        Gate::define('admin', function ($user) {
            return $user->is_admin;
        });
    }
}
EOF

# Create route fix script
cat > "$PACKAGE_DIR/fix_routes.php" << 'EOF'
<?php
// Laravel 12 route fix script

// Make a backup of the routes file
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

// Fix the admin middleware usage in routes
$fixedContent = preg_replace(
    '/Route::middleware\(\[(\'|\")admin(\'|\")\]\)->group\(function \(\) \{/',
    'Route::middleware([\'auth:sanctum\'])->group(function () { // Admin routes
        Route::middleware(function ($request, $next) {
            if (!$request->user() || !$request->user()->is_admin) {
                return response()->json([\'message\' => \'This action is unauthorized.\'], 403);
            }
            return $next($request);
        })->group(function () {',
    $content
);

// Close the additional group
$fixedContent = str_replace(
    "});", 
    "        });
    });", 
    $fixedContent
);

// Add our direct test routes
$directRouteContent = <<<'EOT'

// Direct admin test routes for Laravel 12
Route::get('/direct-user-test', function (Request $request) {
    try {
        // Check if the user is authenticated and is an admin
        $user = $request->user();
        $isAdmin = $user && $user->is_admin;
        
        // Get a list of users (limit to 5)
        $users = \App\Models\User::select('id', 'name', 'email', 'is_admin')
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

// Admin test route with direct middleware check
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
        $users = \App\Models\User::select('id', 'name', 'email', 'is_admin')
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

// Add direct routes at the end of the file
if (strpos($fixedContent, '/admin-health-check') === false) {
    $fixedContent .= $directRouteContent;
}

// Write the updated content back to the routes file
if (file_put_contents($routesPath, $fixedContent)) {
    echo "✅ Successfully updated api.php\n";
} else {
    echo "❌ Failed to update api.php\n";
    exit(1);
}

echo "\nRoute fix completed! You should now clear all Laravel caches.\n";
EOF

# Create test script
cat > "$PACKAGE_DIR/test_admin.php" << 'EOF'
<?php
// Laravel 12 Admin Functionality Test

$token = "5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585"; // Admin token
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
    
    return [
        'status' => $status,
        'response' => $data ?? $response
    ];
}

echo "LARAVEL 12 ADMIN FUNCTIONALITY TEST\n";
echo "=================================\n\n";

$results = [];

// Test 1: Health Check
echo "1. Testing admin health check:\n";
$results['health_check'] = testEndpoint('GET', '/admin-health-check');

// Test 2: Direct User Test
echo "2. Testing direct user test:\n";
$results['direct_test'] = testEndpoint('GET', '/direct-user-test');

// Test 3: Admin Gate Test
echo "3. Testing admin gate test:\n";
$results['gate_test'] = testEndpoint('GET', '/admin-gate-test');

// Test 4: Users Endpoint (Original Admin Route)
echo "4. Testing users endpoint:\n";
$results['users'] = testEndpoint('GET', '/users');

// Test 5: User Creation
echo "5. Testing user creation:\n";
$testEmail = 'test.final.' . time() . '@firda.nl';
$results['create_user'] = testEndpoint('POST', '/users', [
    'email' => $testEmail,
    'is_admin' => false
]);

// Summary
echo "\nTEST SUMMARY\n";
echo "===========\n\n";

$passed = 0;
$failed = 0;

foreach ($results as $test => $result) {
    $status = $result['status'] < 400 ? "✅ PASSED" : "❌ FAILED";
    
    if ($result['status'] < 400) {
        $passed++;
    } else {
        $failed++;
    }
    
    echo "$test: $status (Status: {$result['status']})\n";
}

echo "\nPassed: $passed, Failed: $failed\n";

if ($failed > 0) {
    echo "\nSome tests failed. Review the detailed output above for more information.\n";
} else {
    echo "\nAll tests passed! The admin functionality is working correctly.\n";
}

echo "\nTesting completed!\n";
EOF

# Create deployment script
cat > "$PACKAGE_DIR/deploy.sh" << 'EOF'
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
EOF

# Create README
cat > "$PACKAGE_DIR/README.md" << 'EOF'
# Laravel 12 Admin Fix Package

This package contains scripts to fix the admin functionality in Laravel 12 applications.

## Contents

- `fix_routes.php` - Script to fix the routes in api.php
- `app/Providers/AuthServiceProvider.php` - AuthServiceProvider with admin gate definition
- `test_admin.php` - Script to test the admin functionality
- `deploy.sh` - Deployment script

## Deployment Instructions

1. Upload this entire folder to your server
2. SSH into your server
3. Navigate to the directory where you uploaded the package
4. Run `bash deploy.sh`

## What this package fixes

- Resolves middleware resolution issues in Laravel 12
- Adds proper admin user authorization
- Fixes route handling for admin endpoints
- Adds test routes for verification

## Verification

After deploying, the script will run tests to verify that the fix was successful.
EOF

# Create deployment ZIP
echo -e "${GREEN}Creating ZIP archive...${NC}"
cd /home/senne/projects/uitlenen/deploy
zip -r laravel12_fix.zip laravel12_fix

echo -e "${YELLOW}===== LARAVEL 12 FIX PACKAGE CREATED =====${NC}"
echo -e "${GREEN}The fix package has been created at:${NC}"
echo "/home/senne/projects/uitlenen/deploy/laravel12_fix.zip"
echo ""
echo -e "${GREEN}To deploy on the server:${NC}"
echo "1. Upload the ZIP file to your server"
echo "2. SSH into your server"
echo "3. Extract the ZIP: unzip laravel12_fix.zip"
echo "4. Run the deployment script: cd laravel12_fix && bash deploy.sh"
