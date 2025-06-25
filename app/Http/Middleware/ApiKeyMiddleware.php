<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use App\Models\ApiKey;

class ApiKeyMiddleware
{
    /**
     * Handle an incoming request and validate the API key.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Check if API key is present in request header
        $apiKey = $request->header('X-API-KEY');
        
        if (!$apiKey) {
            return response()->json([
                'status' => 'error',
                'message' => 'API key is missing in request header (X-API-KEY)'
            ], 401);
        }

        // Check if API key exists and is active
        $keyModel = ApiKey::where('key', $apiKey)->first();
        
        if (!$keyModel) {
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid API key'
            ], 401);
        }

        if (!$keyModel->active) {
            return response()->json([
                'status' => 'error',
                'message' => 'This API key has been deactivated'
            ], 403);
        }

        // Update last_used_at timestamp
        $keyModel->last_used_at = now();
        $keyModel->save();

        return $next($request);
    }
}
