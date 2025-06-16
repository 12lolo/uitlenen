<?php
/**
 * Direct Admin Functionality Test
 * 
 * This script can be uploaded to the server and run directly to test admin functionality
 * without requiring token input. It uses Laravel's internal auth mechanism.
 */

// Bootstrap Laravel application
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use App\Models\User;
use Illuminate\Http\Request;

// Output header
echo "========== DIRECT ADMIN FUNCTIONALITY TEST ==========\n\n";

// Find an admin user or create one if needed
$adminUser = User::where('is_admin', true)->first();

if (!$adminUser) {
    echo "No admin user found. Creating a temporary admin user...\n";
    
    // Create temporary admin
    $adminUser = User::create([
        'name' => 'Temporary Admin',
        'email' => 'temp_admin_' . Str::random(8) . '@firda.nl',
        'password' => Hash::make('temp_password_' . Str::random(8)),
        'is_admin' => true,
        'setup_completed' => true,
        'email_verified_at' => now(),
    ]);
    
    echo "Created temporary admin: {$adminUser->email}\n";
} else {
    echo "Found existing admin user: {$adminUser->email}\n";
}

// Login as admin
Auth::login($adminUser);
echo "Logged in as admin: " . Auth::user()->email . "\n\n";

// Test functions
function testEndpoint($method, $uri, $data = []) {
    echo "Testing: $method $uri\n";
    
    $request = Request::create($uri, $method, $data);
    $request->headers->set('Accept', 'application/json');
    
    // Set authenticated user on request
    $request->setUserResolver(function () {
        return Auth::user();
    });
    
    // Dispatch request through the application
    $response = app()->handle($request);
    
    $statusCode = $response->getStatusCode();
    $content = $response->getContent();
    
    echo "Status: $statusCode\n";
    echo "Response: $content\n\n";
    
    return $response;
}

// Run tests
echo "1. Testing Admin Health Check\n";
testEndpoint('GET', '/api/admin-health-check');

echo "2. Testing Admin Gate\n";
testEndpoint('GET', '/api/admin-gate-test');

echo "3. Testing User Listing\n";
testEndpoint('GET', '/api/users');

echo "4. Testing Regular User Creation\n";
$regularEmail = 'test_regular_' . time() . '@firda.nl';
$regularResponse = testEndpoint('POST', '/api/users', [
    'email' => $regularEmail,
    'is_admin' => false
]);

echo "5. Testing Admin User Creation\n";
$adminEmail = 'test_admin_' . time() . '@firda.nl';
$adminResponse = testEndpoint('POST', '/api/users', [
    'email' => $adminEmail,
    'is_admin' => true
]);

// Check for password exposure
echo "6. Checking for Password Exposure\n";
$checkResponse = testEndpoint('POST', '/api/users', [
    'email' => 'password_check_' . time() . '@firda.nl',
    'is_admin' => false
]);

if (strpos($checkResponse->getContent(), 'temp_password') !== false) {
    echo "FAIL: Password is still exposed in the response!\n";
} else {
    echo "PASS: Password is not exposed in the response.\n";
}

echo "\n========== TEST COMPLETED ==========\n";
echo "Admin functionality test completed.\n";
echo "Created test users:\n";
echo "- Regular user: $regularEmail\n";
echo "- Admin user: $adminEmail\n";
