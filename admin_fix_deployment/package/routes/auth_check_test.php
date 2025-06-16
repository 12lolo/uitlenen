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
