<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class Test
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        return json_encode([
            'message' => 'This is a test middleware response.',
            'request_method' => $request->method(),
            'request_uri' => $request->getRequestUri(),
        ]);
        return $next($request);
    }
}
