#!/bin/bash
# Final AuthServiceProvider Fix for Laravel 12 Admin

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

echo -e "${YELLOW}===== APPLYING FINAL AUTH PROVIDER FIX =====${NC}"

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

# 1. Ensure the Providers directory exists
echo -e "${YELLOW}Creating Providers directory if needed...${NC}"
remote_exec "mkdir -p $REMOTE_PATH/app/Providers"

# 2. Upload the AuthServiceProvider.php file
echo -e "${YELLOW}Uploading AuthServiceProvider.php...${NC}"
upload_file "/home/senne/projects/uitlenen/app/Providers/AuthServiceProvider.php" "$REMOTE_PATH/app/Providers/AuthServiceProvider.php"

# 3. Register the provider in config/app.php
echo -e "${YELLOW}Creating script to register AuthServiceProvider...${NC}"

cat > /tmp/register_auth_provider.php << 'EOF'
<?php
// Script to register AuthServiceProvider in config/app.php

$configPath = __DIR__ . '/config/app.php';
$backupPath = $configPath . '.bak_' . date('Ymd_His');

echo "REGISTERING AUTH SERVICE PROVIDER\n";
echo "===============================\n\n";

if (!file_exists($configPath)) {
    echo "❌ ERROR: app.php config file not found\n";
    exit(1);
}

// Create a backup
if (copy($configPath, $backupPath)) {
    echo "✅ Created backup at {$backupPath}\n";
} else {
    echo "❌ Failed to create backup, stopping for safety\n";
    exit(1);
}

// Read the config file
$content = file_get_contents($configPath);
if ($content === false) {
    echo "❌ Failed to read config file\n";
    exit(1);
}

// Check if AuthServiceProvider is already registered
if (strpos($content, 'App\Providers\AuthServiceProvider::class') !== false) {
    echo "✅ AuthServiceProvider is already registered\n";
} else {
    // Find the providers array
    if (preg_match('/\'providers\'\s*=>\s*\[\s*(.*?)\s*\]/s', $content, $matches)) {
        $providersContent = $matches[1];
        
        // Add AuthServiceProvider before RouteServiceProvider
        if (strpos($providersContent, 'App\Providers\RouteServiceProvider::class') !== false) {
            $newProvidersContent = str_replace(
                'App\Providers\RouteServiceProvider::class',
                "App\Providers\AuthServiceProvider::class,\n        App\Providers\RouteServiceProvider::class",
                $providersContent
            );
            $content = str_replace($providersContent, $newProvidersContent, $content);
            
            if (file_put_contents($configPath, $content)) {
                echo "✅ Successfully registered AuthServiceProvider\n";
            } else {
                echo "❌ Failed to update config file\n";
                exit(1);
            }
        } else {
            echo "❌ Could not find RouteServiceProvider in providers array\n";
            
            // As a fallback, try to add it at the end of the providers array
            $newProvidersContent = rtrim($providersContent) . ",\n        App\Providers\AuthServiceProvider::class,\n    ";
            $content = str_replace($providersContent, $newProvidersContent, $content);
            
            if (file_put_contents($configPath, $content)) {
                echo "✅ Added AuthServiceProvider at the end of providers array\n";
            } else {
                echo "❌ Failed to update config file\n";
                exit(1);
            }
        }
    } else {
        echo "❌ Could not find providers array in config file\n";
        exit(1);
    }
}

// Create a direct fix for admin routes
$routesPath = __DIR__ . '/routes/api.php';
$content = file_get_contents($routesPath);

if ($content !== false) {
    // Change middleware(['admin']) to middleware('can:admin')
    $updatedContent = str_replace(
        "middleware('can:admin')",
        "middleware(['can:admin'])",
        $content
    );
    
    if ($updatedContent !== $content) {
        if (file_put_contents($routesPath, $updatedContent)) {
            echo "✅ Updated admin middleware syntax in routes\n";
        } else {
            echo "❌ Failed to update routes file\n";
        }
    } else {
        echo "✓ No changes needed for admin middleware in routes\n";
    }
}

echo "\nAuthServiceProvider registration completed!\n";
EOF

upload_file "/tmp/register_auth_provider.php" "$REMOTE_PATH/register_auth_provider.php"

# 4. Run the registration script
echo -e "${YELLOW}Running AuthServiceProvider registration script...${NC}"
remote_exec "cd $REMOTE_PATH && php register_auth_provider.php"

# 5. Clear all Laravel caches
echo -e "${YELLOW}Clearing Laravel caches...${NC}"
remote_exec "cd $REMOTE_PATH && php artisan config:clear"
remote_exec "cd $REMOTE_PATH && php artisan route:clear"
remote_exec "cd $REMOTE_PATH && php artisan view:clear"
remote_exec "cd $REMOTE_PATH && php artisan cache:clear"

# 6. Create a final test script
echo -e "${YELLOW}Creating final test script...${NC}"

cat > /tmp/final_admin_test.php << 'EOF'
<?php
// Final test script for Laravel 12 admin functionality

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
    
    return [
        'status' => $status,
        'response' => $data ?? $response
    ];
}

echo "FINAL LARAVEL 12 ADMIN FUNCTIONALITY TEST\n";
echo "=====================================\n\n";

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
    
    if ($results['users']['status'] >= 400 && $results['gate_test']['status'] < 400) {
        echo "\nRECOMMENDATION: The admin gate is working, but the original admin routes are not.\n";
        echo "This suggests that there's an issue with how the middleware is registered or used in the routes.\n";
        echo "Consider modifying the routes to use the admin gate directly:\n";
        echo "Route::middleware(['can:admin'])->group(function () { ... })\n";
    }
} else {
    echo "\nAll tests passed! The admin functionality is working correctly.\n";
}

echo "\nTesting completed!\n";
EOF

upload_file "/tmp/final_admin_test.php" "$REMOTE_PATH/final_admin_test.php"

# 7. Run the final test script
echo -e "${YELLOW}Running final admin test...${NC}"
remote_exec "cd $REMOTE_PATH && php final_admin_test.php"

echo -e "${YELLOW}===== FINAL AUTH PROVIDER FIX COMPLETED =====${NC}"
echo -e "${GREEN}Next steps:${NC}"
echo "1. Verify that the admin functionality is working properly in your application"
echo "2. If any issues remain, check the detailed test output above"
echo "3. Remove the temporary scripts when done with this command:"
echo "   ssh -p $PORT $USER@$SERVER \"rm $REMOTE_PATH/register_auth_provider.php $REMOTE_PATH/final_admin_test.php\""
echo ""
echo -e "${YELLOW}If there are any issues, backups of all modified files were created on the server${NC}"
