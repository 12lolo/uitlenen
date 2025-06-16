<?php
// Server-side verification script for admin fix

echo "SERVER-SIDE ADMIN FIX VERIFICATION\n";
echo "===============================\n\n";

// 1. Check Kernel.php
echo "1. Checking Kernel.php for routeMiddleware:\n";
$kernelPath = __DIR__ . '/app/Http/Kernel.php';
if (file_exists($kernelPath)) {
    $kernelContent = file_get_contents($kernelPath);
    
    // Check for routeMiddleware
    if (preg_match('/protected\s+\$routeMiddleware\s*=/s', $kernelContent)) {
        echo "✅ routeMiddleware property found\n";
        
        // Check for admin middleware
        if (strpos($kernelContent, "'admin' => \\App\\Http\\Middleware\\AdminMiddleware::class") !== false) {
            echo "✅ Admin middleware is properly registered\n";
        } else {
            echo "❌ Admin middleware not found in routeMiddleware\n";
        }
    } else {
        echo "❌ routeMiddleware property not found\n";
    }
} else {
    echo "❌ Kernel.php file not found\n";
}

// 2. Check AdminMiddleware
echo "\n2. Checking AdminMiddleware:\n";
$middlewarePath = __DIR__ . '/app/Http/Middleware/AdminMiddleware.php';
if (file_exists($middlewarePath)) {
    echo "✅ AdminMiddleware.php exists\n";
} else {
    echo "❌ AdminMiddleware.php not found\n";
}

// 3. Check routes
echo "\n3. Checking API routes:\n";
$routesPath = __DIR__ . '/routes/api.php';
if (file_exists($routesPath)) {
    $routesContent = file_get_contents($routesPath);
    
    // Check for array middleware syntax
    if (strpos($routesContent, "middleware(['admin'])") !== false) {
        echo "✅ Routes using correct array middleware syntax\n";
    } else if (strpos($routesContent, "middleware('admin')") !== false) {
        echo "❌ Routes using string middleware syntax\n";
    } else {
        echo "❓ No admin middleware found in routes\n";
    }
} else {
    echo "❌ api.php file not found\n";
}

// 4. Check if the fix was successful by directly checking the middleware registration
echo "\n4. Testing route registration:\n";
require_once __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

// Import required classes
use Illuminate\Support\Facades\Route;

// Check if the 'admin' middleware is registered in Laravel's route middleware collection
$routes = Route::getRoutes();
$hasAdminMiddleware = false;

// Find a route that uses admin middleware
foreach ($routes as $route) {
    if (in_array('admin', $route->middleware())) {
        $hasAdminMiddleware = true;
        break;
    }
}

if ($hasAdminMiddleware) {
    echo "✅ 'admin' middleware is being used by routes\n";
} else {
    echo "❌ No routes found using 'admin' middleware\n";
}

// Try to manually resolve the admin middleware
try {
    $router = app('router');
    $reflection = new ReflectionClass($router);
    $property = $reflection->getProperty('middleware');
    $property->setAccessible(true);
    $middlewareList = $property->getValue($router);
    
    if (isset($middlewareList['admin'])) {
        echo "✅ 'admin' middleware is registered in the router\n";
    } else {
        echo "❌ 'admin' middleware is NOT registered in the router\n";
    }
} catch (Exception $e) {
    echo "❌ Error checking middleware registration: " . $e->getMessage() . "\n";
}

echo "\nVerification completed!\n";
