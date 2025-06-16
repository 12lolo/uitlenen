<?php
// A simple PHP script to test admin functionality with the API

$token = "5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585";
$baseUrl = "https://uitleensysteemfirda.nl/api";

// Function to make API requests
function makeRequest($method, $endpoint, $data = null) {
    global $token, $baseUrl;
    
    $ch = curl_init($baseUrl . $endpoint);
    
    // Set common options
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Authorization: Bearer ' . $token
    ]);
    
    // For POST or PUT requests, add the JSON data
    if ($data && ($method == 'POST' || $method == 'PUT')) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    }
    
    // Execute the request
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    return [
        'code' => $httpCode,
        'response' => json_decode($response, true)
    ];
}

echo "===== TESTING ADMIN FUNCTIONALITY =====\n\n";

echo "1. Getting all users (admin only)...\n";
$getAllUsersResult = makeRequest('GET', '/users');
print_r($getAllUsersResult);

echo "\n2. Getting user format guide...\n";
$formatGuideResult = makeRequest('GET', '/users/format');
print_r($formatGuideResult);

// Generate a unique email for testing
$testEmail = "test" . time() . "@firda.nl";

echo "\n3. Creating a new test user ($testEmail)...\n";
$createUserResult = makeRequest('POST', '/users', [
    'email' => $testEmail,
    'is_admin' => false
]);

print_r($createUserResult);

echo "\n===== ADMIN FUNCTIONALITY TESTING COMPLETED =====\n";
