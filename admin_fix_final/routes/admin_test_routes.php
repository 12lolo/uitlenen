<?php
// Admin test routes

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

// Direct admin check test
Route::get('/admin-direct-test', function (Request $request) {
    $isAdmin = Auth::check() && Auth::user()->is_admin;
    
    return response()->json([
        'status' => 'success',
        'message' => $isAdmin ? 'You are an admin' : 'You are NOT an admin',
        'authenticated' => Auth::check(),
        'is_admin' => $isAdmin,
        'user_details' => Auth::check() ? Auth::user()->only('id', 'name', 'email', 'is_admin') : null,
        'timestamp' => now()->toIso8601String()
    ]);
})->middleware('auth:sanctum');

// Admin middleware test
Route::get('/admin-middleware-test', function (Request $request) {
    return response()->json([
        'status' => 'success',
        'message' => 'Admin middleware test passed',
        'user_details' => Auth::user()->only('id', 'name', 'email', 'is_admin'),
        'timestamp' => now()->toIso8601String()
    ]);
})->middleware(['auth:sanctum', 'admin']);

// Direct controller action test
Route::get('/admin-controller-test', function (Request $request) {
    $controller = new \App\Http\Controllers\UserController();
    return $controller->index();
})->middleware('auth:sanctum');

// Health check ping
Route::get('/admin-ping', function () {
    return response()->json([
        'status' => 'success',
        'message' => 'Admin routes are accessible',
        'timestamp' => now()->toIso8601String()
    ]);
});
