<?php
// Local test for admin routes
// This will directly test the routes without token authentication

// Get any command line arguments
$baseUrl = isset($argv[1]) ? $argv[1] : "http://localhost:8000";

echo "===== TESTING ADMIN ROUTES WITHOUT AUTH =====\n";
echo "Base URL: $baseUrl\n\n";

// Function to make a simple request without authentication
function makeSimpleRequest($url, $method = 'GET') {
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    return [
        'code' => $httpCode,
        'response' => $response
    ];
}

// Test the health check endpoint
echo "1. Testing health check endpoint...\n";
$result = makeSimpleRequest("$baseUrl/api/admin-health-check");
echo "Status code: " . $result['code'] . "\n";
echo "Response: " . $result['response'] . "\n\n";

echo "===== TEST COMPLETED =====\n";
