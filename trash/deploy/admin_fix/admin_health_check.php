<?php
// Admin health check routes

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;

// Add a health check route that doesn't require authentication
Route::get('/admin-health-check', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'Admin routes are being loaded',
        'timestamp' => now()->toIso8601String()
    ]);
});

// Direct test route without admin middleware
Route::get('/direct-user-test', function (Request $request) {
    try {
        $users = \App\Models\User::select('id', 'name', 'email', 'is_admin')
            ->limit(5)
            ->get();
            
        return response()->json([
            'status' => 'success',
            'message' => 'Direct test successful',
            'current_user' => $request->user() ? $request->user()->only('id', 'name', 'email', 'is_admin') : null,
            'users' => $users
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => $e->getMessage(),
            'trace' => $e->getTraceAsString()
        ], 500);
    }
})->middleware('auth:sanctum');
