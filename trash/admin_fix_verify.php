<?php
// Verify Admin Functionality Fix

namespace App\Tests;

// Load Laravel
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;
use App\Models\User;
use App\Http\Middleware\AdminMiddleware;
use Illuminate\Support\Str;

echo "ADMIN FUNCTIONALITY FIX VERIFICATION\n";
echo "==================================\n\n";

// Part 1: Check middleware registration
echo "Part 1: Middleware Registration\n";
$kernel = app(\Illuminate\Contracts\Http\Kernel::class);
// Instead of getRouteMiddleware(), use reflection to get the protected property
$reflection = new \ReflectionClass($kernel);
$property = $reflection->getProperty('routeMiddleware');
$property->setAccessible(true);
$routeMiddleware = $property->getValue($kernel);

if (isset($routeMiddleware['admin'])) {
    echo "✓ 'admin' middleware is registered as: " . $routeMiddleware['admin'] . "\n";
    
    if (class_exists($routeMiddleware['admin'])) {
        echo "✓ The middleware class exists\n";
        
        try {
            $instance = app($routeMiddleware['admin']);
            echo "✓ Middleware can be resolved from container\n";
        } catch (\Exception $e) {
            echo "✗ Error resolving middleware: " . $e->getMessage() . "\n";
        }
    } else {
        echo "✗ The middleware class does not exist\n";
    }
} else {
    echo "✗ 'admin' middleware is not registered\n";
}

echo "\n";

// Part 2: Check admin routes
echo "Part 2: Admin Routes\n";
$routes = Route::getRoutes();
$adminRoutes = [];

foreach ($routes as $route) {
    if (in_array('admin', $route->middleware())) {
        $adminRoutes[] = [
            'uri' => $route->uri(),
            'methods' => $route->methods(),
            'action' => $route->getActionName()
        ];
    }
}

if (count($adminRoutes) > 0) {
    echo "✓ Found " . count($adminRoutes) . " routes with admin middleware\n";
    
    foreach ($adminRoutes as $index => $route) {
        echo "  " . ($index + 1) . ". " . implode(', ', $route['methods']) . " /" . $route['uri'] . " → " . $route['action'] . "\n";
    }
} else {
    echo "✗ No routes with admin middleware found\n";
}

echo "\n";

// Part 3: Test AdminMiddleware directly
echo "Part 3: AdminMiddleware Logic\n";

// Create a mock request
$request = new \Illuminate\Http\Request();

// Create a mock admin user
$adminUser = new class extends \stdClass {
    public $id = 1;
    public $name = 'Admin User';
    public $email = 'admin@firda.nl';
    public $is_admin = true;
};

// Create a mock non-admin user
$regularUser = new class extends \stdClass {
    public $id = 2;
    public $name = 'Regular User';
    public $email = 'user@firda.nl';
    public $is_admin = false;
};

// Create reflection method to set protected properties
$requestReflection = new \ReflectionClass($request);
$userProperty = $requestReflection->getProperty('user');
$userProperty->setAccessible(true);

// Test with admin user
$userProperty->setValue($request, $adminUser);
$middleware = new AdminMiddleware();

try {
    $response = $middleware->handle($request, function($req) {
        return new \Illuminate\Http\Response('Success');
    });
    
    if ($response->getStatusCode() === 200) {
        echo "✓ Admin user passed middleware check\n";
    } else {
        echo "✗ Admin user failed middleware check with status " . $response->getStatusCode() . "\n";
    }
} catch (\Exception $e) {
    echo "✗ Error testing admin user: " . $e->getMessage() . "\n";
}

// Test with non-admin user
$userProperty->setValue($request, $regularUser);

try {
    $response = $middleware->handle($request, function($req) {
        return new \Illuminate\Http\Response('Should not reach here');
    });
    
    if ($response->getStatusCode() === 403) {
        echo "✓ Non-admin user correctly blocked with 403\n";
    } else {
        echo "✗ Non-admin user incorrectly allowed through with status " . $response->getStatusCode() . "\n";
    }
} catch (\Exception $e) {
    echo "✗ Error testing non-admin user: " . $e->getMessage() . "\n";
}

echo "\n";

// Part 4: Generate admin access token for API testing
echo "Part 4: Generate Admin Access Token\n";

try {
    // Find an admin user or create one if needed
    $user = User::where('is_admin', true)->first();
    
    if (!$user) {
        echo "No admin user found, creating one...\n";
        $user = new User([
            'name' => 'Test Admin',
            'email' => 'test.admin.' . time() . '@firda.nl',
            'password' => bcrypt('password123'),
            'is_admin' => true,
            'email_verified_at' => now()
        ]);
        $user->save();
    }
    
    // Generate a token
    $token = $user->createToken('admin-test-token')->plainTextToken;
    
    echo "✓ Admin token generated: " . $token . "\n";
    echo "✓ User ID: " . $user->id . ", Name: " . $user->name . ", Email: " . $user->email . "\n";
    
    // Save token to file for later use
    file_put_contents(__DIR__ . '/admin_token.txt', $token);
    echo "✓ Token saved to admin_token.txt\n";
} catch (\Exception $e) {
    echo "✗ Error generating admin token: " . $e->getMessage() . "\n";
}

echo "\nVerification completed!\n";
