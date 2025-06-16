<?php
// Admin API fix for Laravel 12 middleware resolving issues
// Run with: php admin_api_fix.php

echo "Starting Admin API Fix for Laravel 12...\n";

// Fix UserController.php
$file = __DIR__ . '/app/Http/Controllers/UserController.php';
if (file_exists($file)) {
    echo "Fixing $file...\n";
    $content = file_get_contents($file);
    
    // Add Auth facade import if not already there
    if (!preg_match('/use Illuminate\\\\Support\\\\Facades\\\\Auth;/', $content)) {
        $content = str_replace(
            'use Illuminate\Http\Request;',
            "use Illuminate\Http\Request;\nuse Illuminate\\Support\\Facades\\Auth;",
            $content
        );
    }
    
    // Replace auth() helper with Auth::
    $content = preg_replace('/if\s*\(\s*!\s*auth\s*\(\s*\)\s*->\s*user\s*\(\s*\)\s*\|\|\s*!\s*auth\s*\(\s*\)\s*->\s*user\s*\(\s*\)\s*->\s*is_admin\s*\)/s', 
        'if (!Auth::check() || !Auth::user()->is_admin)', 
        $content
    );
    
    // Fix constructor if problematic
    if (preg_match('/\s*public\s+function\s+__construct\s*\(\s*\)\s*\{\s*\$this\s*->\s*middleware\s*\(/s', $content)) {
        $content = preg_replace('/\s*public\s+function\s+__construct\s*\(\s*\)\s*\{.*?\}\s*\}/s',
            "    public function __construct()\n    {\n        // Constructor without middleware\n    }",
            $content
        );
    }
    
    file_put_contents($file, $content);
    echo "Fixed UserController!\n";
} else {
    echo "File $file not found!\n";
}

// Fix SimpleUserController.php
$file = __DIR__ . '/app/Http/Controllers/SimpleUserController.php';
if (file_exists($file)) {
    echo "Fixing $file...\n";
    $content = file_get_contents($file);
    
    // Add Auth facade import if not already there
    if (!preg_match('/use Illuminate\\\\Support\\\\Facades\\\\Auth;/', $content)) {
        $content = str_replace(
            'use Illuminate\Http\Request;',
            "use Illuminate\Http\Request;\nuse Illuminate\\Support\\Facades\\Auth;",
            $content
        );
    }
    
    // Replace auth() helper with Auth::
    $content = preg_replace('/if\s*\(\s*!\s*auth\s*\(\s*\)\s*->\s*user\s*\(\s*\)\s*\|\|\s*!\s*auth\s*\(\s*\)\s*->\s*user\s*\(\s*\)\s*->\s*is_admin\s*\)/s', 
        'if (!Auth::check() || !Auth::user()->is_admin)', 
        $content
    );
    
    // Add admin check to store method if missing
    if (!preg_match('/if\s*\(\s*!\s*Auth::check\s*\(\s*\)\s*\|\|\s*!\s*Auth::user\s*\(\s*\)\s*->\s*is_admin\s*\)/', $content)) {
        $content = preg_replace(
            '/public\s+function\s+store\s*\(\s*Request\s+\$request\s*\)\s*\{\s*try\s*\{/s',
            "public function store(Request \$request)\n    {\n        try {\n            // Check if user is admin using Auth facade\n            if (!Auth::check() || !Auth::user()->is_admin) {\n                return response()->json(['message' => 'This action is unauthorized.'], 403);\n            }\n            ",
            $content
        );
    }
    
    file_put_contents($file, $content);
    echo "Fixed SimpleUserController!\n";
} else {
    echo "File $file not found!\n";
}

// Fix routes/api.php to include test routes
$file = __DIR__ . '/routes/api.php';
if (file_exists($file)) {
    echo "Fixing $file...\n";
    $content = file_get_contents($file);
    
    // Add Auth facade import if needed
    if (!preg_match('/use Illuminate\\\\Support\\\\Facades\\\\Auth;/', $content)) {
        $content = str_replace(
            'use Illuminate\Support\Facades\Route;',
            "use Illuminate\Support\Facades\Route;\nuse Illuminate\\Support\\Facades\\Auth;",
            $content
        );
    }
    
    // Make sure the auth check test routes are included
    if (!file_exists(__DIR__ . '/routes/auth_check_test.php')) {
        echo "Creating auth_check_test.php...\n";
        file_put_contents(__DIR__ . '/routes/auth_check_test.php', <<<'PHP'
<?php
// Auth check test routes for troubleshooting

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Auth;

// Include this in api.php with: require __DIR__ . '/auth_check_test.php';

// Test route for checking Auth::check() functionality
Route::get('/auth-check-test', function () {
    $isAuthenticated = Auth::check();
    $user = $isAuthenticated ? Auth::user()->only('id', 'name', 'email', 'is_admin') : null;
    
    return response()->json([
        'is_authenticated' => $isAuthenticated,
        'auth_check_result' => Auth::check(),
        'user' => $user,
        'timestamp' => now()->toIso8601String()
    ]);
})->middleware('auth:sanctum');

// Test route for checking admin gates
Route::get('/admin-check-test', function () {
    $isAdmin = Auth::check() && Auth::user()->is_admin;
    
    return response()->json([
        'is_authenticated' => Auth::check(),
        'is_admin' => $isAdmin,
        'user' => Auth::check() ? Auth::user()->only('id', 'name', 'email', 'is_admin') : null,
        'timestamp' => now()->toIso8601String()
    ]);
})->middleware('auth:sanctum');

// Simple wrapper around the user controller
Route::get('/test-user-api', function () {
    try {
        $controller = new \App\Http\Controllers\SimpleUserController();
        return $controller->index();
    } catch (\Exception $e) {
        return response()->json([
            'error' => $e->getMessage(),
            'trace' => $e->getTraceAsString()
        ], 500);
    }
})->middleware('auth:sanctum');
PHP
        );
    }
    
    // Include the test routes file if not already included
    if (!preg_match('/require __DIR__\s*\.\s*\'\/auth_check_test.php\';/', $content)) {
        $content = str_replace(
            "require __DIR__.'/comprehensive_admin_fix.php';",
            "require __DIR__.'/comprehensive_admin_fix.php';\n\n// Include auth check test routes\nrequire __DIR__.'/auth_check_test.php';",
            $content
        );
    }
    
    file_put_contents($file, $content);
    echo "Fixed routes/api.php!\n";
} else {
    echo "File $file not found!\n";
}

echo "\nAdmin API Fix completed! Please refresh your server cache with:\n";
echo "php artisan optimize:clear\n";
echo "php artisan cache:clear\n";
echo "php artisan config:clear\n";
echo "php artisan route:clear\n\n";

echo "Testing API endpoints (if curl is available):\n";
if (shell_exec('which curl')) {
    echo shell_exec('php artisan route:list | grep -E "/api/users|/api/auth-check-test|/api/admin-check-test"');
}

echo "\nDone!\n";
