<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class LogoutMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->is('api/logout') && !$request->user()) {
            return response()->json([
                'message' => 'Je bent niet ingelogd. Log in om uit te kunnen loggen.',
                'error' => 'Niet ingelogd',
                'status_code' => 401
            ], 401);
        }

        return $next($request);
    }
}
