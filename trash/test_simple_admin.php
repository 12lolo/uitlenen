<?php
// Test script for the simplified admin functionality

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
    
    // For debugging
    if ($httpCode >= 400) {
        echo "Error with status code $httpCode\n";
        echo "URL: $baseUrl$endpoint\n";
        echo "Response: $response\n\n";
    }
    
    curl_close($ch);
    
    return [
        'code' => $httpCode,
        'response' => json_decode($response, true)
    ];
}

echo "===== TESTING SIMPLIFIED ADMIN FUNCTIONALITY =====\n\n";

// First, check if the current user is an admin
echo "1. Checking current user...\n";
$userResult = makeRequest('GET', '/user');
print_r($userResult);

$isAdmin = $userResult['response']['is_admin'] ?? false;
if (!$isAdmin) {
    echo "WARNING: Current user is not an admin. Admin functionality tests may fail.\n\n";
}

echo "2. Getting all users with simplified controller (admin only)...\n";
$getAllUsersResult = makeRequest('GET', '/simple-users');
print_r($getAllUsersResult);

// Generate a unique email for testing
$testEmail = "simple_test" . time() . "@firda.nl";

echo "\n3. Creating a new test user with simplified controller ($testEmail)...\n";
$createUserResult = makeRequest('POST', '/simple-users', [
    'email' => $testEmail,
    'is_admin' => false
]);

print_r($createUserResult);

echo "\n===== SIMPLIFIED ADMIN FUNCTIONALITY TESTING COMPLETED =====\n";
