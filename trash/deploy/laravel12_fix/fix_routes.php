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
