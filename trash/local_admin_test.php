<?php
/**
 * Local Admin Functionality Test
 * 
 * This script tests admin functionality directly in the local environment
 * without requiring remote API calls
 */

// Bootstrap Laravel application
require __DIR__ . '/vendor/autoload.php';

// Create application
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

echo "========== LOCAL ADMIN FUNCTIONALITY TEST ==========\n\n";

// Find admin user or create one
echo "1. Checking for admin user\n";
$adminUser = User::where('is_admin', true)->first();

if (!$adminUser) {
    echo "No admin user found. Creating a temporary admin user...\n";
    
    $adminUser = User::create([
        'name' => 'Local Test Admin',
        'email' => 'local_admin_' . Str::random(8) . '@firda.nl',
        'password' => Hash::make('password_' . Str::random(8)),
        'is_admin' => true,
        'email_verified_at' => now(),
        'setup_completed' => true,
    ]);
    
    echo "Created admin user: {$adminUser->email}\n";
} else {
    echo "Found existing admin user: {$adminUser->email}\n";
}

// Login as admin
Auth::login($adminUser);
echo "Logged in as admin: {$adminUser->email}\n\n";

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
    echo "Response: " . substr($content, 0, 500) . (strlen($content) > 500 ? '...' : '') . "\n\n";
    
    return $response;
}

// 2. Test admin functionality
echo "2. Testing Admin Health Check\n";
testEndpoint('GET', '/api/admin-health-check');

echo "3. Testing Admin Gate\n";
testEndpoint('GET', '/api/admin-gate-test');

echo "4. Testing User Listing\n";
testEndpoint('GET', '/api/users');

// 5. Test user creation
echo "5. Testing Regular User Creation\n";
$regularEmail = 'test_regular_' . time() . '@firda.nl';
$regularResponse = testEndpoint('POST', '/api/users', [
    'email' => $regularEmail,
    'is_admin' => false
]);

echo "6. Testing Admin User Creation\n";
$adminEmail = 'test_admin_' . time() . '@firda.nl';
$adminResponse = testEndpoint('POST', '/api/users', [
    'email' => $adminEmail,
    'is_admin' => true
]);

// 7. Check password exposure
echo "7. Checking for Password Exposure\n";
$passwordResponse = testEndpoint('POST', '/api/users', [
    'email' => 'password_test_' . time() . '@firda.nl',
    'is_admin' => false
]);

if (strpos($passwordResponse->getContent(), 'temp_password') !== false) {
    echo "SECURITY ISSUE: Password is still exposed in the response!\n";
} else {
    echo "Security check passed: No password exposed in response.\n";
}

// 8. Check admin middleware
echo "8. Testing Admin Middleware in Kernel.php\n";
$routeMiddleware = app('router')->getMiddleware();
if (isset($routeMiddleware['admin'])) {
    echo "Admin middleware is registered correctly: " . $routeMiddleware['admin'] . "\n";
} else {
    echo "Admin middleware is NOT registered in route middleware!\n";
}

// 9. Check middleware registration
echo "9. Checking Middleware Registration in Kernel\n";
$kernel = app(\Illuminate\Contracts\Http\Kernel::class);
try {
    $reflectionClass = new ReflectionClass($kernel);
    $routeMiddlewareProperty = $reflectionClass->getProperty('routeMiddleware');
    $routeMiddlewareProperty->setAccessible(true);
    $routeMiddleware = $routeMiddlewareProperty->getValue($kernel);
    
    if (isset($routeMiddleware['admin'])) {
        echo "Admin middleware is registered in Kernel routeMiddleware: " . $routeMiddleware['admin'] . "\n";
    } else {
        echo "Admin middleware is NOT registered in Kernel routeMiddleware!\n";
    }
} catch (\Exception $e) {
    echo "Error inspecting Kernel: " . $e->getMessage() . "\n";
}

echo "\n========== TEST SUMMARY ==========\n";
echo "Admin health check: TESTED\n";
echo "Admin gate: TESTED\n";
echo "User listing: TESTED\n";
echo "User creation: TESTED\n";
echo "Admin creation: TESTED\n";
echo "Password security: TESTED\n";
echo "Middleware registration: TESTED\n";
echo "\nCreated test users:\n";
echo "- Regular user: $regularEmail\n";
echo "- Admin user: $adminEmail\n";
echo "\n===============================\n";
