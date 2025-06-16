<?php
// Dedicated admin routes

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;
use Illuminate\Support\Facades\Auth;

// All routes in this file are under the 'admin' prefix and require 'auth:sanctum' middleware
Route::prefix('admin')->middleware('auth:sanctum')->group(function () {
    
    // Admin-only routes that don't use the admin middleware but check inside controller
    Route::get('/users', [UserController::class, 'index']);
    Route::post('/users', [UserController::class, 'store']);
    
    // Direct admin checks without middleware
    Route::get('/check', function () {
        if (!Auth::check() || !Auth::user()->is_admin) {
            return response()->json(['message' => 'This action is unauthorized.'], 403);
        }
        
        return response()->json([
            'message' => 'Admin check passed',
            'user' => Auth::user()->only('id', 'name', 'email', 'is_admin')
        ]);
    });
    
    // System status for admins
    Route::get('/status', function () {
        if (!Auth::check() || !Auth::user()->is_admin) {
            return response()->json(['message' => 'This action is unauthorized.'], 403);
        }
        
        return response()->json([
            'app_name' => config('app.name'),
            'app_env' => config('app.env'),
            'app_debug' => config('app.debug'),
            'server_time' => now()->toIso8601String(),
            'php_version' => PHP_VERSION,
            'laravel_version' => app()->version(),
            'admin_user' => Auth::user()->only('id', 'name', 'email')
        ]);
    });
});

// Health check endpoint (public)
Route::get('/admin-status', function () {
    return response()->json([
        'status' => 'online',
        'timestamp' => now()->toIso8601String()
    ]);
});
