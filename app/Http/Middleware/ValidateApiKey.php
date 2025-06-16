<?php

namespace App\Http\Middleware;

use App\Models\ApiKey;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class ValidateApiKey
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Check for API key in header
        $apiKey = $request->header('X-API-KEY');
        
        if (!$apiKey) {
            return response()->json([
                'message' => 'API key is missing',
            ], 401);
        }
        
        // Find and validate API key
        $keyModel = ApiKey::where('key', $apiKey)->first();
        
        if (!$keyModel || !$keyModel->isValid()) {
            return response()->json([
                'message' => 'Invalid API key',
            ], 401);
        }
        
        // Add API key to request for later use if needed
        $request->attributes->set('api_key', $keyModel);
        
        return $next($request);
    }
}
