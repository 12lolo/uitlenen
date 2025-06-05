<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Define a named login route for the middleware to redirect to
Route::get('/login', function() {
    return redirect('/api/login');
})->name('login');
