<?php
// Test admin routes registration

namespace App\Tests;

use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Route;

// Load Laravel
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

echo "Testing Admin Routes Registration\n";
echo "================================\n\n";

// Get all registered routes
$routes = Route::getRoutes();

// Look for admin routes
$adminRoutes = [];
$adminMiddlewareRoutes = [];

foreach ($routes as $route) {
    $uri = $route->uri();
    $methods = $route->methods();
    $name = $route->getName() ?? 'unnamed';
    $action = $route->getActionName();
    $middleware = $route->middleware();
    
    // Check if this is relevant to admin functionality
    if (strpos($uri, 'user') !== false || 
        strpos($uri, 'admin') !== false || 
        strpos($action, 'UserController') !== false) {
        
        $adminRoutes[] = [
            'uri' => $uri,
            'methods' => $methods,
            'name' => $name,
            'action' => $action,
            'middleware' => $middleware
        ];
    }
    
    // Check specifically for admin middleware
    if (in_array('admin', $middleware) || in_array(['admin'], $middleware)) {
        $adminMiddlewareRoutes[] = [
            'uri' => $uri,
            'methods' => $methods,
            'name' => $name,
            'action' => $action,
            'middleware' => $middleware
        ];
    }
}

// Display admin-related routes
echo "Found " . count($adminRoutes) . " admin-related routes:\n";
foreach ($adminRoutes as $index => $route) {
    echo "\n" . ($index + 1) . ". Route: " . implode(', ', $route['methods']) . " /" . $route['uri'] . "\n";
    echo "   Action: " . $route['action'] . "\n";
    echo "   Middleware: " . implode(', ', $route['middleware']) . "\n";
}

// Display routes with admin middleware
echo "\n\nFound " . count($adminMiddlewareRoutes) . " routes with admin middleware:\n";
foreach ($adminMiddlewareRoutes as $index => $route) {
    echo "\n" . ($index + 1) . ". Route: " . implode(', ', $route['methods']) . " /" . $route['uri'] . "\n";
    echo "   Action: " . $route['action'] . "\n";
    echo "   Middleware: " . implode(', ', $route['middleware']) . "\n";
}

// Test route resolution
echo "\n\nTesting route resolution for key admin endpoints:\n";

function testRoute($method, $uri) {
    echo "Testing $method /$uri: ";
    try {
        $route = Route::getRoutes()->match(
            \Illuminate\Http\Request::create("/$uri", $method)
        );
        echo "✓ Route resolves to " . $route->getActionName() . "\n";
        echo "  Middleware: " . implode(', ', $route->middleware()) . "\n";
        return true;
    } catch (\Exception $e) {
        echo "✗ Route failed: " . $e->getMessage() . "\n";
        return false;
    }
}

// Test key routes
testRoute('GET', 'api/users');
testRoute('POST', 'api/users');
testRoute('GET', 'api/simple-users');
testRoute('GET', 'api/admin-health-check');
testRoute('GET', 'api/direct-user-test');

echo "\nTest completed.\n";
