<?php
// API Test Script for Admin Functionality

// Set your base URL and test data
$baseUrl = 'http://localhost:8000/api'; // Change this to your actual base URL
$adminEmail = 'admin@firda.nl';
$adminPassword = 'password123';
$testUserEmail = 'test.user.' . time() . '@firda.nl';

echo "ADMIN API FUNCTIONALITY TEST\n";
echo "===========================\n\n";

// Function to make API requests
function makeRequest($method, $endpoint, $data = null, $token = null) {
    global $baseUrl;
    
    $url = $baseUrl . $endpoint;
    echo "Request: $method $url\n";
    
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    
    $headers = ['Accept: application/json', 'Content-Type: application/json'];
    if ($token) {
        $headers[] = 'Authorization: Bearer ' . $token;
    }
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    
    if ($data && ($method == 'POST' || $method == 'PUT')) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    }
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);
    curl_close($ch);
    
    if ($error) {
        echo "Error: $error\n";
    }
    
    echo "Status: $httpCode\n";
    $responseData = json_decode($response, true);
    
    return [
        'code' => $httpCode,
        'response' => $responseData,
        'raw' => $response
    ];
}

// Function to print test results
function printResult($testName, $result, $expectedCode = 200) {
    echo "\n===== $testName =====\n";
    echo "Status Code: " . $result['code'] . " (Expected: $expectedCode)\n";
    
    if ($result['code'] == $expectedCode) {
        echo "✅ Test Passed\n";
    } else {
        echo "❌ Test Failed\n";
    }
    
    echo "Response:\n";
    echo json_encode($result['response'], JSON_PRETTY_PRINT) . "\n";
    echo "====================\n\n";
}

// Test 1: Health Check
$healthCheck = makeRequest('GET', '/admin-health-check');
printResult('Health Check', $healthCheck);

// Test 2: Login as admin
$loginResult = makeRequest('POST', '/login', [
    'email' => $adminEmail,
    'password' => $adminPassword
]);
printResult('Admin Login', $loginResult, 200);

// If login was successful, get the token
$token = null;
if ($loginResult['code'] == 200 && isset($loginResult['response']['token'])) {
    $token = $loginResult['response']['token'];
    echo "Admin Token: $token\n\n";
} else {
    // Try to use a token from file if login failed
    if (file_exists(__DIR__ . '/admin_token.txt')) {
        $token = trim(file_get_contents(__DIR__ . '/admin_token.txt'));
        echo "Using token from file: $token\n\n";
    } else {
        echo "❌ No admin token available. Stopping tests.\n";
        exit(1);
    }
}

// Test 3: Access admin route - Get all users
$usersResult = makeRequest('GET', '/users', null, $token);
printResult('Get All Users (Admin)', $usersResult);

// Test 4: Create a new user as admin
$createUserResult = makeRequest('POST', '/users', [
    'email' => $testUserEmail,
    'is_admin' => false
], $token);
printResult('Create User (Admin)', $createUserResult, 201);

// Test 5: Use SimpleUserController as a fallback
$simpleUsersResult = makeRequest('GET', '/simple-users', null, $token);
printResult('Get All Users (Simple Admin)', $simpleUsersResult);

// Test 6: Test direct user route (no admin middleware)
$directTestResult = makeRequest('GET', '/direct-user-test', null, $token);
printResult('Direct User Test', $directTestResult);

echo "All tests completed!\n";
