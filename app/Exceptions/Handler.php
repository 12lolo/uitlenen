<?php

namespace App\Exceptions;

use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Symfony\Component\HttpKernel\Exception\MethodNotAllowedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\Route;
use Throwable;

class Handler extends ExceptionHandler
{
    /**
     * The list of the inputs that are never flashed to the session on validation exceptions.
     *
     * @var array<int, string>
     */
    protected $dontFlash = [
        'current_password',
        'password',
        'password_confirmation',
    ];

    /**
     * Register the exception handling callbacks for the application.
     */
    public function register(): void
    {
        $this->reportable(function (Throwable $e) {
            //
        });

        // Handle MethodNotAllowedHttpException specifically for the logout endpoint
        $this->renderable(function (MethodNotAllowedHttpException $e, $request) {
            if ($request->is('api/logout')) {
                return response()->json([
                    'message' => 'Je bent niet ingelogd. Log in om deze functie te gebruiken.',
                    'error' => 'Niet ingelogd',
                    'status_code' => 401
                ], 401);
            }
            
            // Generic handler for other MethodNotAllowedHttpException
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'message' => 'De gebruikte HTTP-methode is niet toegestaan voor deze route.',
                    'error' => 'Method Not Allowed',
                    'status_code' => 405
                ], 405);
            }
            
            return null;
        });

        // Improve API error responses for other exception types
        $this->renderable(function (Throwable $e, $request) {
            if ($request->expectsJson() || $request->is('api/*')) {
                if ($e instanceof NotFoundHttpException) {
                    return response()->json([
                        'message' => 'De opgevraagde route bestaat niet.',
                        'error' => 'Not Found',
                        'status_code' => 404
                    ], 404);
                }
                
                if ($e instanceof AuthenticationException) {
                    $path = $request->path();
                    
                    // Customize message for specific endpoints
                    if ($path === 'api/logout') {
                        return response()->json([
                            'message' => 'Je bent niet ingelogd. Log in om uit te kunnen loggen.',
                            'error' => 'Niet ingelogd',
                            'status_code' => 401
                        ], 401);
                    }
                    
                    return response()->json([
                        'message' => 'Je bent niet geauthenticeerd. Log in om toegang te krijgen.',
                        'error' => 'Unauthorized',
                        'status_code' => 401
                    ], 401);
                }
                
                if ($e instanceof AuthorizationException) {
                    return response()->json([
                        'message' => 'Je hebt geen toegang tot deze functionaliteit.',
                        'error' => 'Forbidden',
                        'status_code' => 403
                    ], 403);
                }
                
                if ($e instanceof ModelNotFoundException) {
                    return response()->json([
                        'message' => 'Het opgevraagde item kon niet worden gevonden.',
                        'error' => 'Not Found',
                        'status_code' => 404
                    ], 404);
                }
                
                if ($e instanceof ValidationException) {
                    return response()->json([
                        'message' => 'De ingevoerde gegevens zijn ongeldig.',
                        'errors' => $e->validator->errors(),
                        'status_code' => 422
                    ], 422);
                }
            }
            
            return null; // Let Laravel handle other exceptions
        });
    }
}
