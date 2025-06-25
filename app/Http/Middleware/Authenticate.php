<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class Authenticate extends Middleware
{
    /**
     * Handle an unauthenticated user.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  array  $guards
     * @return void
     *
     * @throws \Illuminate\Auth\AuthenticationException
     */
    protected function unauthenticated($request, array $guards)
    {
        if ($request->expectsJson() || $request->is('api/*')) {
            // Check if the request is for the logout endpoint
            if ($request->is('api/logout')) {
                abort(response()->json([
                    'message' => 'Je bent niet ingelogd. Log in om uit te kunnen loggen.',
                    'error' => 'Niet ingelogd',
                    'status_code' => 401
                ], 401));
            }
            
            // Check if it's for the items endpoint
            if ($request->is('api/items')) {
                abort(response()->json([
                    'message' => 'Je moet ingelogd zijn om alle items te bekijken.',
                    'error' => 'Niet ingelogd',
                    'status_code' => 401
                ], 401));
            }
            
            abort(response()->json([
                'message' => 'Je bent niet geauthenticeerd. Log in om toegang te krijgen.',
                'error' => 'Niet ingelogd',
                'status_code' => 401
            ], 401));
        }

        parent::unauthenticated($request, $guards);
    }

    /**
     * Get the path the user should be redirected to when they are not authenticated.
     */
    protected function redirectTo(Request $request): ?string
    {
        return $request->expectsJson() ? null : route('login');
    }
}
