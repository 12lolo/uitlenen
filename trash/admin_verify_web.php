<?php
// Web-based verification for admin functionality fix
// Save this file to your production server as admin_verify_web.php

// Set headers for JSON output
header('Content-Type: application/json');

// Security check - replace this with a secure token of your choice
$secret_key = 'fix_admin_june_2025';
if (!isset($_GET['key']) || $_GET['key'] !== $secret_key) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Unauthorized access. Please provide the correct key.'
    ]);
    exit;
}

// Store results
$results = [
    'status' => 'running',
    'timestamp' => date('Y-m-d H:i:s'),
    'tests' => []
];

// Test 1: Check if UserController exists and has proper syntax
$results['tests']['userController'] = [
    'name' => 'UserController File Check',
    'status' => 'running'
];

$userControllerPath = __DIR__ . '/app/Http/Controllers/UserController.php';
if (file_exists($userControllerPath)) {
    $content = file_get_contents($userControllerPath);
    if (strpos($content, 'class UserController extends Controller') !== false) {
        $results['tests']['userController']['status'] = 'passed';
        $results['tests']['userController']['message'] = 'UserController exists and has proper class definition';
    } else {
        $results['tests']['userController']['status'] = 'failed';
        $results['tests']['userController']['message'] = 'UserController exists but might have syntax issues';
    }
} else {
    $results['tests']['userController']['status'] = 'failed';
    $results['tests']['userController']['message'] = 'UserController file not found';
}

// Test 2: Check if SimpleUserController exists
$results['tests']['simpleUserController'] = [
    'name' => 'SimpleUserController File Check',
    'status' => 'running'
];

$simpleControllerPath = __DIR__ . '/app/Http/Controllers/SimpleUserController.php';
if (file_exists($simpleControllerPath)) {
    $results['tests']['simpleUserController']['status'] = 'passed';
    $results['tests']['simpleUserController']['message'] = 'SimpleUserController exists';
} else {
    $results['tests']['simpleUserController']['status'] = 'failed';
    $results['tests']['simpleUserController']['message'] = 'SimpleUserController file not found';
}

// Test 3: Check routes file for proper middleware syntax
$results['tests']['routesSyntax'] = [
    'name' => 'Routes Middleware Syntax Check',
    'status' => 'running'
];

$routesPath = __DIR__ . '/routes/api.php';
if (file_exists($routesPath)) {
    $routesContent = file_get_contents($routesPath);
    if (strpos($routesContent, "Route::middleware(['admin'])") !== false) {
        $results['tests']['routesSyntax']['status'] = 'passed';
        $results['tests']['routesSyntax']['message'] = 'Routes file has correct middleware syntax';
    } else {
        $results['tests']['routesSyntax']['status'] = 'failed';
        $results['tests']['routesSyntax']['message'] = 'Routes file does not have correct middleware syntax';
    }
} else {
    $results['tests']['routesSyntax']['status'] = 'failed';
    $results['tests']['routesSyntax']['message'] = 'Routes file not found';
}

// Test 4: Check if health check route file exists and is included
$results['tests']['healthCheckRoute'] = [
    'name' => 'Health Check Routes File Check',
    'status' => 'running'
];

$healthCheckPath = __DIR__ . '/routes/admin_health_check.php';
if (file_exists($healthCheckPath)) {
    $results['tests']['healthCheckRoute']['status'] = 'passed';
    $results['tests']['healthCheckRoute']['message'] = 'Health check routes file exists';
    
    // Check if it's included in api.php
    if (strpos($routesContent, "require __DIR__.'/admin_health_check.php'") !== false) {
        $results['tests']['healthCheckRoute']['message'] .= ' and is included in api.php';
    } else {
        $results['tests']['healthCheckRoute']['message'] .= ' but might not be included in api.php';
    }
} else {
    $results['tests']['healthCheckRoute']['status'] = 'failed';
    $results['tests']['healthCheckRoute']['message'] = 'Health check routes file not found';
}

// Test 5: Check if admin middleware is registered in Kernel.php
$results['tests']['middlewareRegistration'] = [
    'name' => 'Admin Middleware Registration Check',
    'status' => 'running'
];

$kernelPath = __DIR__ . '/app/Http/Kernel.php';
if (file_exists($kernelPath)) {
    $kernelContent = file_get_contents($kernelPath);
    if (strpos($kernelContent, "'admin' => \\App\\Http\\Middleware\\AdminMiddleware::class") !== false) {
        $results['tests']['middlewareRegistration']['status'] = 'passed';
        $results['tests']['middlewareRegistration']['message'] = 'Admin middleware is properly registered in Kernel.php';
    } else {
        $results['tests']['middlewareRegistration']['status'] = 'failed';
        $results['tests']['middlewareRegistration']['message'] = 'Admin middleware might not be properly registered in Kernel.php';
    }
} else {
    $results['tests']['middlewareRegistration']['status'] = 'failed';
    $results['tests']['middlewareRegistration']['message'] = 'Kernel.php file not found';
}

// Test 6: Check AdminMiddleware file
$results['tests']['adminMiddleware'] = [
    'name' => 'AdminMiddleware File Check',
    'status' => 'running'
];

$middlewarePath = __DIR__ . '/app/Http/Middleware/AdminMiddleware.php';
if (file_exists($middlewarePath)) {
    $results['tests']['adminMiddleware']['status'] = 'passed';
    $results['tests']['adminMiddleware']['message'] = 'AdminMiddleware file exists';
} else {
    $results['tests']['adminMiddleware']['status'] = 'failed';
    $results['tests']['adminMiddleware']['message'] = 'AdminMiddleware file not found';
}

// Test 7: Check recent Laravel logs for errors
$results['tests']['errorLogs'] = [
    'name' => 'Error Logs Check',
    'status' => 'running'
];

$logsPath = __DIR__ . '/storage/logs/';
$logFiles = glob($logsPath . 'laravel-*.log');
if (!empty($logFiles)) {
    $latestLog = end($logFiles);
    $logContent = file_exists($latestLog) ? file_get_contents($latestLog) : '';
    
    // Check for admin-related errors in the last 100 lines
    $logLines = explode("\n", $logContent);
    $logLines = array_slice($logLines, -100);
    $relevantErrors = [];
    
    foreach ($logLines as $line) {
        if (strpos($line, 'admin') !== false && (
            strpos($line, 'error') !== false || 
            strpos($line, 'exception') !== false || 
            strpos($line, 'Error') !== false || 
            strpos($line, 'Exception') !== false
        )) {
            $relevantErrors[] = $line;
        }
    }
    
    if (empty($relevantErrors)) {
        $results['tests']['errorLogs']['status'] = 'passed';
        $results['tests']['errorLogs']['message'] = 'No admin-related errors found in recent logs';
    } else {
        $results['tests']['errorLogs']['status'] = 'warning';
        $results['tests']['errorLogs']['message'] = 'Found ' . count($relevantErrors) . ' admin-related errors in recent logs';
        $results['tests']['errorLogs']['errors'] = array_slice($relevantErrors, 0, 5); // Show up to 5 errors
    }
} else {
    $results['tests']['errorLogs']['status'] = 'warning';
    $results['tests']['errorLogs']['message'] = 'No log files found';
}

// Calculate overall status
$passed = 0;
$failed = 0;
$warnings = 0;

foreach ($results['tests'] as $test) {
    if ($test['status'] === 'passed') {
        $passed++;
    } elseif ($test['status'] === 'failed') {
        $failed++;
    } elseif ($test['status'] === 'warning') {
        $warnings++;
    }
}

$results['summary'] = [
    'passed' => $passed,
    'failed' => $failed,
    'warnings' => $warnings,
    'total' => count($results['tests'])
];

if ($failed > 0) {
    $results['status'] = 'failed';
} elseif ($warnings > 0) {
    $results['status'] = 'warning';
} else {
    $results['status'] = 'passed';
}

// Add some useful next steps
$results['next_steps'] = [
    'Test the health check endpoint directly: https://uitleensysteemfirda.nl/api/admin-health-check',
    'Test admin endpoints with a valid token using Postman or similar tool',
    'Check Laravel logs for more detailed error information',
    'If issues persist, consider restoring from backups in /backups/admin_fix_20250611/'
];

// Output results as JSON
echo json_encode($results, JSON_PRETTY_PRINT);
