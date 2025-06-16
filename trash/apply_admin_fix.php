<?php
// Comprehensive fix script for admin functionality

// Load Laravel
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Artisan;

echo "APPLYING COMPREHENSIVE ADMIN FIX\n";
echo "===============================\n\n";

try {
    // Step 1: Fix Kernel.php to properly register the admin middleware
    echo "Step 1: Fixing Kernel.php middleware registration\n";
    
    $kernelPath = app_path('Http/Kernel.php');
    $kernelContent = File::get($kernelPath);
    
    // Create a backup
    File::put($kernelPath . '.bak', $kernelContent);
    echo "✓ Created Kernel.php backup\n";
    
    // Ensure routeMiddleware property is present for Laravel version compatibility
    if (!preg_match('/protected\s+\$routeMiddleware\s*=/s', $kernelContent)) {
        // Find the end of the class
        $lastBracePos = strrpos($kernelContent, '}');
        
        // Insert routeMiddleware property before the end of the class
        $routeMiddlewareCode = <<<'CODE'
    
    /**
     * The application's route middleware.
     *
     * For Laravel compatibility, explicitly registering the admin middleware.
     *
     * @var array<string, class-string|string>
     */
    protected $routeMiddleware = [
        'admin' => \App\Http\Middleware\AdminMiddleware::class,
        'check.invitation' => \App\Http\Middleware\CheckInvitationExpiry::class,
        'checkinvitation' => \App\Http\Middleware\CheckInvitationExpiry::class,
    ];
CODE;
        
        $updatedContent = substr_replace($kernelContent, $routeMiddlewareCode, $lastBracePos, 0);
        File::put($kernelPath, $updatedContent);
        echo "✓ Added routeMiddleware property to Kernel.php\n";
    } else {
        echo "✓ routeMiddleware property already exists\n";
        
        // Update the existing routeMiddleware property to include admin
        $updatedContent = preg_replace(
            '/(protected\s+\$routeMiddleware\s*=\s*\[\s*(?:\'[^\']+\'\s*=>\s*[^,]+,\s*)*)\]\s*;/s',
            '$1\'admin\' => \\App\\Http\\Middleware\\AdminMiddleware::class,
        \'check.invitation\' => \\App\\Http\\Middleware\\CheckInvitationExpiry::class,
        \'checkinvitation\' => \\App\\Http\\Middleware\\CheckInvitationExpiry::class,
    ];',
            $kernelContent
        );
        
        if ($updatedContent !== $kernelContent) {
            File::put($kernelPath, $updatedContent);
            echo "✓ Updated routeMiddleware property to include admin middleware\n";
        } else {
            echo "✓ Admin middleware already in routeMiddleware\n";
        }
    }
    
    // Step 2: Ensure the AdminMiddleware class is present and properly implemented
    echo "\nStep 2: Verifying AdminMiddleware implementation\n";
    
    $middlewarePath = app_path('Http/Middleware/AdminMiddleware.php');
    
    if (!File::exists($middlewarePath)) {
        echo "! AdminMiddleware file not found, creating it...\n";
        
        $middlewareContent = <<<'CODE'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminMiddleware
{
    /**
     * Handle an incoming request and check for admin privileges.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (!$request->user() || !$request->user()->is_admin) {
            return response()->json([
                'status' => 'error',
                'message' => 'Unauthorized. Admin privileges required.'
            ], 403);
        }

        return $next($request);
    }
}
CODE;
        
        File::put($middlewarePath, $middlewareContent);
        echo "✓ Created AdminMiddleware.php\n";
    } else {
        echo "✓ AdminMiddleware.php exists\n";
    }
    
    // Step 3: Update routes to use the correct middleware syntax
    echo "\nStep 3: Fixing routes middleware syntax\n";
    
    $routesPath = base_path('routes/api.php');
    $routesContent = File::get($routesPath);
    
    // Ensure we're using array syntax for middleware
    $updatedRoutes = preg_replace('/middleware\s*\(\s*[\'"]admin[\'"]\s*\)/', 'middleware([\'admin\'])', $routesContent);
    
    if ($updatedRoutes !== $routesContent) {
        File::put($routesPath, $updatedRoutes);
        echo "✓ Updated routes to use array syntax for middleware\n";
    } else {
        echo "✓ Routes already using correct middleware syntax\n";
    }
    
    // Step 4: Clear all caches
    echo "\nStep 4: Clearing all Laravel caches\n";
    
    Artisan::call('cache:clear');
    echo "✓ Application cache cleared\n";
    
    Artisan::call('config:clear');
    echo "✓ Configuration cache cleared\n";
    
    Artisan::call('route:clear');
    echo "✓ Route cache cleared\n";
    
    Artisan::call('view:clear');
    echo "✓ View cache cleared\n";
    
    echo "\nAdmin fix successfully applied!\n";
    
} catch (\Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString() . "\n";
    exit(1);
}
