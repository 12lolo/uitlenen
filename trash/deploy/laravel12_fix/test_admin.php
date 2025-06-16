<?php
// Laravel 12 Admin Functionality Test

$token = "5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585"; // Admin token
$baseUrl = "https://uitleensysteemfirda.nl/api";

function testEndpoint($method, $endpoint, $data = null) {
    global $token, $baseUrl;
    
    echo "Testing $method $endpoint\n";
    
    $curl = curl_init($baseUrl . $endpoint);
    curl_setopt($curl, CURLOPT_CUSTOMREQUEST, $method);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curl, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . $token,
        'Content-Type: application/json',
        'Accept: application/json'
    ]);
    
    if ($data && ($method == 'POST' || $method == 'PUT')) {
        curl_setopt($curl, CURLOPT_POSTFIELDS, json_encode($data));
    }
    
    $response = curl_exec($curl);
    $status = curl_getinfo($curl, CURLINFO_HTTP_CODE);
    $error = curl_error($curl);
    curl_close($curl);
    
    echo "Status: $status\n";
    
    if ($error) {
        echo "Error: $error\n";
    } else {
        $data = json_decode($response, true);
        if (json_last_error() === JSON_ERROR_NONE) {
            echo "Response: " . json_encode($data, JSON_PRETTY_PRINT) . "\n";
        } else {
            echo "Response: $response\n";
        }
    }
    
    echo "\n----------------------------------\n\n";
    
    return [
        'status' => $status,
        'response' => $data ?? $response
    ];
}

echo "LARAVEL 12 ADMIN FUNCTIONALITY TEST\n";
echo "=================================\n\n";

$results = [];

// Test 1: Health Check
echo "1. Testing admin health check:\n";
$results['health_check'] = testEndpoint('GET', '/admin-health-check');

// Test 2: Direct User Test
echo "2. Testing direct user test:\n";
$results['direct_test'] = testEndpoint('GET', '/direct-user-test');

// Test 3: Admin Gate Test
echo "3. Testing admin gate test:\n";
$results['gate_test'] = testEndpoint('GET', '/admin-gate-test');

// Test 4: Users Endpoint (Original Admin Route)
echo "4. Testing users endpoint:\n";
$results['users'] = testEndpoint('GET', '/users');

// Test 5: User Creation
echo "5. Testing user creation:\n";
$testEmail = 'test.final.' . time() . '@firda.nl';
$results['create_user'] = testEndpoint('POST', '/users', [
    'email' => $testEmail,
    'is_admin' => false
]);

// Summary
echo "\nTEST SUMMARY\n";
echo "===========\n\n";

$passed = 0;
$failed = 0;

foreach ($results as $test => $result) {
    $status = $result['status'] < 400 ? "✅ PASSED" : "❌ FAILED";
    
    if ($result['status'] < 400) {
        $passed++;
    } else {
        $failed++;
    }
    
    echo "$test: $status (Status: {$result['status']})\n";
}

echo "\nPassed: $passed, Failed: $failed\n";

if ($failed > 0) {
    echo "\nSome tests failed. Review the detailed output above for more information.\n";
} else {
    echo "\nAll tests passed! The admin functionality is working correctly.\n";
}

echo "\nTesting completed!\n";
