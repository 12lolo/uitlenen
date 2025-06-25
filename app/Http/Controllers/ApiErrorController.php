<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ApiErrorController extends Controller
{
    /**
     * Handle API errors in a user-friendly way
     */
    public function handleLogoutError()
    {
        return response()->json([
            'message' => 'Je bent niet ingelogd. Log in om uit te kunnen loggen.',
            'error' => 'Niet ingelogd',
            'status_code' => 401
        ], 401);
    }
}
