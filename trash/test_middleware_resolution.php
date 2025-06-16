<?php
// Test the admin middleware resolution issue

// Load Laravel
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

echo "Testing Admin Middleware Resolution\n";
echo "=================================\n\n";

// 1. Verify the middleware is properly registered
echo "1. Checking middleware registration:\n";
$kernel = app(\Illuminate\Contracts\Http\Kernel::class);
// Use reflection to access protected property
$reflection = new \ReflectionClass($kernel);
$property = $reflection->getProperty('routeMiddleware');
$property->setAccessible(true);
$routeMiddleware = $property->getValue($kernel);

if (isset($routeMiddleware['admin'])) {
    echo "✅ 'admin' middleware is registered as: " . $routeMiddleware['admin'] . "\n";
    
    // Check if the class exists
    if (class_exists($routeMiddleware['admin'])) {
        echo "✅ The middleware class exists\n";
    } else {
        echo "❌ The middleware class does not exist\n";
    }
} else {
    echo "❌ 'admin' middleware is not registered in Kernel.php\n";
}

// 2. Test resolving the middleware through the container
echo "\n2. Testing middleware resolution through container:\n";
try {
    $middleware = app('middleware.admin');
    echo "✅ Successfully resolved 'middleware.admin' from container\n";
} catch (\Exception $e) {
    echo "❌ Failed to resolve 'middleware.admin': " . $e->getMessage() . "\n";
}

try {
    $middleware = app('App\Http\Middleware\AdminMiddleware');
    echo "✅ Successfully resolved AdminMiddleware class from container\n";
} catch (\Exception $e) {
    echo "❌ Failed to resolve AdminMiddleware class: " . $e->getMessage() . "\n";
}

// 3. Test resolving just 'admin'
echo "\n3. Testing direct resolution of 'admin':\n";
try {
    $admin = app('admin');
    echo "✅ Successfully resolved 'admin' from container\n";
} catch (\Exception $e) {
    echo "❌ Failed to resolve 'admin': " . $e->getMessage() . "\n";
}

// 4. Check the routes file syntax
echo "\n4. Checking routes file syntax:\n";
$routesFile = file_get_contents(__DIR__ . '/routes/api.php');

// Look for middleware definitions
if (preg_match('/middleware\s*\(\s*[\'"]admin[\'"]\s*\)/', $routesFile)) {
    echo "⚠️ Found string format middleware: middleware('admin')\n";
} else {
    echo "✅ No string format middleware found\n";
}

if (preg_match('/middleware\s*\(\s*\[\s*[\'"]admin[\'"]\s*\]\s*\)/', $routesFile)) {
    echo "✅ Found array format middleware: middleware(['admin'])\n";
} else {
    echo "⚠️ No array format middleware found\n";
}

// 5. Check admin middleware implementation
echo "\n5. Checking AdminMiddleware implementation:\n";
$middlewareFile = file_get_contents(__DIR__ . '/app/Http/Middleware/AdminMiddleware.php');

if (strpos($middlewareFile, 'handle(Request $request, Closure $next)') !== false) {
    echo "✅ AdminMiddleware has proper handle method signature\n";
} else {
    echo "⚠️ AdminMiddleware handle method signature might be incorrect\n";
}

// 6. Check RouteServiceProvider for middleware groups
echo "\n6. Checking RouteServiceProvider for middleware groups:\n";
$providerFile = file_get_contents(__DIR__ . '/app/Providers/RouteServiceProvider.php');

if (strpos($providerFile, "'admin' => ") !== false) {
    echo "⚠️ Found potential middleware group definition in RouteServiceProvider\n";
} else {
    echo "✅ No conflicting middleware group found in RouteServiceProvider\n";
}

echo "\nTest completed.\n";
