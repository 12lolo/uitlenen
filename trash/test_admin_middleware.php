<?php
// Test Admin Middleware functionality directly

namespace App\Tests;

use App\Http\Middleware\AdminMiddleware;
use Illuminate\Http\Request;
use Illuminate\Foundation\Auth\User;
use Illuminate\Support\Facades\Log;

// Load Laravel
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

echo "Testing AdminMiddleware functionality directly\n";

class MockUser {
    public $is_admin = false;
    
    public function __construct($isAdmin = false) {
        $this->is_admin = $isAdmin;
    }
}

class MockRequest extends Request {
    protected $user;
    
    public function setUser($user) {
        $this->user = $user;
        return $this;
    }
    
    public function user($guard = null) {
        return $this->user;
    }
}

try {
    // 1. Create a middleware instance
    echo "1. Creating AdminMiddleware instance... ";
    $middleware = new AdminMiddleware();
    echo "Success!\n";
    
    // 2. Test with no user (should fail)
    echo "2. Testing with no user... ";
    $request = new MockRequest();
    $response = $middleware->handle($request, function($req) {
        return "Success - should not reach here";
    });
    
    if ($response->getStatusCode() === 403) {
        echo "Success - correctly denied access (status 403)\n";
    } else {
        echo "FAILED - expected 403 but got " . $response->getStatusCode() . "\n";
    }
    
    // 3. Test with non-admin user (should fail)
    echo "3. Testing with non-admin user... ";
    $request = new MockRequest();
    $request->setUser(new MockUser(false));
    $response = $middleware->handle($request, function($req) {
        return "Success - should not reach here";
    });
    
    if ($response->getStatusCode() === 403) {
        echo "Success - correctly denied access (status 403)\n";
    } else {
        echo "FAILED - expected 403 but got " . $response->getStatusCode() . "\n";
    }
    
    // 4. Test with admin user (should pass)
    echo "4. Testing with admin user... ";
    $request = new MockRequest();
    $request->setUser(new MockUser(true));
    $passed = false;
    
    $response = $middleware->handle($request, function($req) use (&$passed) {
        $passed = true;
        return "Success - reached here as expected";
    });
    
    if ($passed) {
        echo "Success - correctly allowed access\n";
    } else {
        echo "FAILED - admin user was denied access\n";
    }
    
    echo "\nTest completed successfully!\n";
    
} catch (\Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString() . "\n";
}
