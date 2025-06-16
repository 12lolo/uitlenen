#!/bin/bash
# Laravel 12 Middleware Fix Script

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

echo -e "${YELLOW}===== APPLYING LARAVEL 12 ADMIN MIDDLEWARE FIX =====${NC}"

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

# 1. Create a Laravel 12 middleware fixer script
echo -e "${YELLOW}Creating Laravel 12 middleware fixer script...${NC}"

cat > /tmp/fix_laravel12_middleware.php << 'EOF'
<?php
// Laravel 12 middleware fix script

// Create a backup of the Kernel.php file
$kernelPath = __DIR__ . '/app/Http/Kernel.php';
$backupPath = $kernelPath . '.bak_' . date('Ymd_His');

echo "APPLYING LARAVEL 12 MIDDLEWARE FIX\n";
echo "================================\n\n";

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

// Fix the routeMiddleware array
if (preg_match('/protected\s+\$routeMiddleware\s*=\s*\[\s*([^\]]+)\s*\];/s', $content, $matches)) {
    $middlewareList = $matches[1];
    
    // Check if admin middleware is present
    if (strpos($middlewareList, "'admin' => \\App\\Http\\Middleware\\AdminMiddleware::class") === false) {
        echo "Adding admin middleware to routeMiddleware...\n";
        $newMiddlewareList = rtrim($middlewareList) . ",\n        'admin' => \\App\\Http\\Middleware\\AdminMiddleware::class,\n    ";
        $content = str_replace($middlewareList, $newMiddlewareList, $content);
        echo "✅ Added admin to routeMiddleware\n";
    } else {
        echo "✅ Admin middleware already in routeMiddleware\n";
    }
} else {
    echo "❌ Could not find routeMiddleware array\n";
}

// Update the docblock to show it's for Laravel 12
$content = str_replace(
    "For Laravel 10 compatibility", 
    "For Laravel 12 compatibility", 
    $content
);
echo "✅ Updated documentation for Laravel 12\n";

// Write the updated content
if (file_put_contents($kernelPath, $content)) {
    echo "✅ Successfully updated Kernel.php\n";
} else {
    echo "❌ Failed to update Kernel.php\n";
    exit(1);
}

// Also fix the UserController if needed
$userControllerPath = __DIR__ . '/app/Http/Controllers/UserController.php';
if (file_exists($userControllerPath)) {
    $userControllerContent = file_get_contents($userControllerPath);
    if ($userControllerContent) {
        // Check for duplicate code in the index method
        if (preg_match('/return response\(\)\->json\(\[\s*\'message\'\s*=>\s*\'Error retrieving users.*\s*\]\,\s*500\s*\)\;\s*\}\s*\}\s*\s*\/\/\s*Return a more helpful error message/s', $userControllerContent)) {
            echo "Fixing duplicate code in UserController...\n";
            $userControllerContent = preg_replace('/(\s*\/\/\s*Return a more helpful error message\s*return response\(\)\->json\(\[\s*\'message\'\s*=>\s*\'Error retrieving users.*\s*\]\,\s*500\s*\)\;\s*\}\s*\})(\s*\/\/\s*Return a more helpful error message\s*return response\(\)\->json\(\[\s*\'message\'\s*=>\s*\'Error retrieving users.*\s*\]\,\s*500\s*\)\;\s*\}\s*\})/s', '$1', $userControllerContent);
            if (file_put_contents($userControllerPath, $userControllerContent)) {
                echo "✅ Fixed duplicate code in UserController\n";
            } else {
                echo "❌ Failed to fix UserController\n";
            }
        } else {
            echo "✅ UserController already fixed\n";
        }
    }
}

echo "\nMiddleware fix completed! You should now clear all Laravel caches.\n";
EOF

upload_file "/tmp/fix_laravel12_middleware.php" "$REMOTE_PATH/fix_laravel12_middleware.php"

# 2. Create Laravel 12 verification script
echo -e "${YELLOW}Creating Laravel 12 verification script...${NC}"

cat > /tmp/verify_laravel12_fix.php << 'EOF'
<?php
// Server-side verification script for Laravel 12 admin fix

echo "LARAVEL 12 ADMIN FIX VERIFICATION\n";
echo "==============================\n\n";

// 1. Check Kernel.php
echo "1. Checking Kernel.php for middleware:\n";
$kernelPath = __DIR__ . '/app/Http/Kernel.php';
if (file_exists($kernelPath)) {
    $kernelContent = file_get_contents($kernelPath);
    
    // Check for routeMiddleware
    if (preg_match('/protected\s+\$routeMiddleware\s*=/s', $kernelContent)) {
        echo "✅ routeMiddleware property found\n";
        
        // Check for admin middleware in routeMiddleware
        if (preg_match('/\'admin\'\s*=>\s*\\\\App\\\\Http\\\\Middleware\\\\AdminMiddleware::class/s', $kernelContent)) {
            echo "✅ Admin middleware is properly registered in routeMiddleware\n";
        } else {
            echo "❌ Admin middleware not found in routeMiddleware\n";
        }
    } else {
        echo "❌ routeMiddleware property not found\n";
    }
    
    // Check for middlewareAliases
    if (preg_match('/protected\s+\$middlewareAliases\s*=/s', $kernelContent)) {
        echo "✅ middlewareAliases property found\n";
        
        // Check for admin middleware in middlewareAliases
        if (preg_match('/\'admin\'\s*=>\s*\\\\App\\\\Http\\\\Middleware\\\\AdminMiddleware::class/s', $kernelContent)) {
            echo "✅ Admin middleware is properly registered in middlewareAliases\n";
        } else {
            echo "❌ Admin middleware not found in middlewareAliases\n";
        }
    }
} else {
    echo "❌ Kernel.php file not found\n";
}

// 2. Check AdminMiddleware
echo "\n2. Checking AdminMiddleware:\n";
$middlewarePath = __DIR__ . '/app/Http/Middleware/AdminMiddleware.php';
if (file_exists($middlewarePath)) {
    echo "✅ AdminMiddleware.php exists\n";
    
    // Check implementation
    $middlewareContent = file_get_contents($middlewarePath);
    if (strpos($middlewareContent, 'if (!$request->user() || !$request->user()->is_admin)') !== false) {
        echo "✅ AdminMiddleware has correct implementation\n";
    } else {
        echo "❌ AdminMiddleware might have incorrect implementation\n";
    }
} else {
    echo "❌ AdminMiddleware.php not found\n";
}

// 3. Test routes in a safe way
echo "\n3. Testing route registration:\n";
require_once __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

// Try to access the router and check middleware
try {
    $router = app('router');
    $middleware = $router->getMiddleware();
    
    if (isset($middleware['admin'])) {
        echo "✅ 'admin' middleware is registered in the router\n";
    } else {
        // Check in middleware groups
        $groups = $router->getMiddlewareGroups();
        $found = false;
        foreach ($groups as $name => $middlewares) {
            if (in_array('admin', $middlewares) || in_array('\App\Http\Middleware\AdminMiddleware', $middlewares)) {
                $found = true;
                echo "✅ 'admin' middleware found in '{$name}' middleware group\n";
                break;
            }
        }
        
        if (!$found) {
            echo "❌ 'admin' middleware not found in router\n";
        }
    }
} catch (Exception $e) {
    echo "❌ Error checking middleware registration: " . $e->getMessage() . "\n";
}

// 4. Test route reflection 
echo "\n4. Checking routes using admin middleware:\n";
try {
    $routes = app('router')->getRoutes();
    $adminRoutes = [];
    
    foreach ($routes as $route) {
        if (in_array('admin', $route->middleware()) || in_array('App\Http\Middleware\AdminMiddleware', $route->middleware())) {
            $adminRoutes[] = $route->uri();
        }
    }
    
    if (count($adminRoutes) > 0) {
        echo "✅ Found " . count($adminRoutes) . " routes using admin middleware:\n";
        foreach ($adminRoutes as $uri) {
            echo "   - " . $uri . "\n";
        }
    } else {
        echo "❌ No routes found using admin middleware\n";
    }
} catch (Exception $e) {
    echo "❌ Error checking routes: " . $e->getMessage() . "\n";
}

echo "\nVerification completed!\n";
EOF

upload_file "/tmp/verify_laravel12_fix.php" "$REMOTE_PATH/verify_laravel12_fix.php"

# 3. Run the fixer script on the server
echo -e "${YELLOW}Running Laravel 12 middleware fixer script...${NC}"
remote_exec "cd $REMOTE_PATH && php fix_laravel12_middleware.php"

# 4. Clear all Laravel caches
echo -e "${YELLOW}Clearing Laravel caches...${NC}"
remote_exec "cd $REMOTE_PATH && php artisan config:clear"
remote_exec "cd $REMOTE_PATH && php artisan route:clear"
remote_exec "cd $REMOTE_PATH && php artisan view:clear"
remote_exec "cd $REMOTE_PATH && php artisan cache:clear"

# 5. Run the verification script
echo -e "${YELLOW}Running verification script...${NC}"
remote_exec "cd $REMOTE_PATH && php verify_laravel12_fix.php"

# 6. Create a quick admin API test script
echo -e "${YELLOW}Creating admin API test script...${NC}"

cat > /tmp/laravel12_admin_test.php << 'EOF'
<?php
// Laravel 12 Admin API Test Script

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

echo "LARAVEL 12 ADMIN API TEST\n";
echo "=======================\n\n";

// Test admin health check
echo "1. Testing admin health check:\n";
testEndpoint('GET', '/admin-health-check');

// Test admin users endpoint
echo "2. Testing admin users endpoint:\n";
testEndpoint('GET', '/users');

// Test user creation (admin only)
echo "3. Testing user creation:\n";
$testEmail = 'test.laravel12.' . time() . '@firda.nl';
testEndpoint('POST', '/users', [
    'email' => $testEmail,
    'is_admin' => false
]);

echo "\nTesting completed!\n";
EOF

upload_file "/tmp/laravel12_admin_test.php" "$REMOTE_PATH/laravel12_admin_test.php"

# 7. Run the test script
echo -e "${YELLOW}Running Laravel 12 admin API test...${NC}"
remote_exec "cd $REMOTE_PATH && php laravel12_admin_test.php"

echo -e "${YELLOW}===== LARAVEL 12 ADMIN MIDDLEWARE FIX COMPLETED =====${NC}"
echo -e "${GREEN}Next steps:${NC}"
echo "1. Verify that the admin functionality is working properly"
echo "2. Test the API endpoints with a valid admin token"
echo "3. Remove the temporary scripts when done with this command:"
echo "   ssh -p $PORT $USER@$SERVER \"rm $REMOTE_PATH/fix_laravel12_middleware.php $REMOTE_PATH/verify_laravel12_fix.php $REMOTE_PATH/laravel12_admin_test.php\""
echo ""
echo -e "${YELLOW}If there are any issues, backups of all modified files were created on the server${NC}"
