<?php

namespace App\Http\Middleware;

use App\Traits\ApiResponser;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class ApiErrorHandlingMiddleware
{
    use ApiResponser;
    
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);
        
        // Check if this is an API request with an error status
        if ($request->is('api/*') && $response->getStatusCode() >= 400) {
            // Special case for logout with 405 error
            if ($request->is('api/logout') && $response->getStatusCode() == 405) {
                return $this->errorResponse(
                    'Je bent niet ingelogd. Log in om uit te kunnen loggen.',
                    401
                );
            }
            
            // For other error responses, if they're not already JSON, convert them
            if (!$response->headers->contains('Content-Type', 'application/json')) {
                $statusCode = $response->getStatusCode();
                
                return $this->errorResponse(
                    $this->getReadableErrorMessage($request, $statusCode),
                    $statusCode
                );
            }
            
            // If it's already JSON but doesn't follow our standard format, standardize it
            if ($response->headers->contains('Content-Type', 'application/json')) {
                $content = json_decode($response->getContent(), true);
                
                // Check if it's not already in our standard format
                if (!isset($content['status']) && !isset($content['status_code'])) {
                    $statusCode = $response->getStatusCode();
                    $message = $content['message'] ?? $this->getReadableErrorMessage($request, $statusCode);
                    
                    return $this->errorResponse(
                        $message,
                        $statusCode,
                        isset($content['errors']) ? $content['errors'] : null
                    );
                }
            }
        }
        
        return $response;
    }
    
    /**
     * Get a more user-friendly error message based on request and status code
     */
    private function getReadableErrorMessage(Request $request, int $statusCode): string
    {
        // Path-specific messages
        $path = $request->path();
        
        if ($path === 'api/logout') {
            return 'Je bent niet ingelogd. Log in om uit te kunnen loggen.';
        }
        
        // Status code-specific messages
        switch ($statusCode) {
            case 401:
                return 'Je bent niet ingelogd. Log in om toegang te krijgen.';
            case 403:
                return 'Je hebt geen toegang tot deze functionaliteit.';
            case 404:
                return 'De opgevraagde route bestaat niet.';
            case 405:
                return 'De gebruikte HTTP-methode is niet toegestaan voor deze route.';
            case 422:
                return 'De ingevoerde gegevens zijn ongeldig.';
            case 429:
                return 'Te veel verzoeken in korte tijd. Probeer het later opnieuw.';
            case 500:
                return 'Er is een interne serverfout opgetreden.';
            default:
                return 'Er is een fout opgetreden bij het verwerken van je verzoek.';
        }
    }
}
