<?php
// Test script for direct admin test route

$token = "5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585";
$baseUrl = "https://uitleensysteemfirda.nl/api";

// Function to make API requests with detailed error reporting
function makeRequest($method, $endpoint, $data = null) {
    global $token, $baseUrl;
    
    $url = $baseUrl . $endpoint;
    echo "Making $method request to: $url\n";
    
    $ch = curl_init($url);
    
    // Set common options
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HEADER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Authorization: Bearer ' . $token
    ]);
    
    // For POST or PUT requests, add the JSON data
    if ($data && ($method == 'POST' || $method == 'PUT')) {
        $jsonData = json_encode($data);
        echo "Request data: $jsonData\n";
        curl_setopt($ch, CURLOPT_POSTFIELDS, $jsonData);
    }
    
    // Execute the request
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $headerSize = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
    $headers = substr($response, 0, $headerSize);
    $body = substr($response, $headerSize);
    
    curl_close($ch);
    
    echo "Response code: $httpCode\n";
    echo "Response headers:\n$headers\n";
    
    return [
        'code' => $httpCode,
        'headers' => $headers,
        'body' => $body,
        'response' => json_decode($body, true)
    ];
}

echo "===== TESTING DIRECT ADMIN TEST ROUTE =====\n\n";

echo "1. Testing direct route...\n";
$directRouteResult = makeRequest('GET', '/test-admin-route');

echo "\nResponse body:\n";
print_r($directRouteResult['response']);

echo "\n===== DIRECT ROUTE TESTING COMPLETED =====\n";
