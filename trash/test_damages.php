<?php
// A simple PHP script to test damage reporting functionality with the API

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

echo "===== TESTING DAMAGE REPORTING FUNCTIONALITY =====\n\n";

echo "1. Getting damage report format guide...\n";
$formatGuideResult = makeRequest('GET', '/items/damage/format');
print_r($formatGuideResult);

echo "\n2. Getting all items...\n";
$getItemsResult = makeRequest('GET', '/items');
// Find an item to report damage on
$testItem = null;
foreach ($getItemsResult['response'] as $item) {
    if (isset($item['id'])) {
        $testItem = $item;
        break;
    }
}

if (!$testItem) {
    die("No items found. Cannot continue testing damage reporting.\n");
}

echo "Found item to test damage reporting: {$testItem['title']} (ID: {$testItem['id']})\n\n";

echo "3. Creating a new damage report...\n";
$createDamageResult = makeRequest('POST', "/items/{$testItem['id']}/damage", [
    'description' => 'Test damage report created via API',
    'severity' => 'minor',
    'student_email' => 'test.student@student.firda.nl'
]);

print_r($createDamageResult);

echo "\n4. Getting all damage reports...\n";
$getDamagesResult = makeRequest('GET', '/damages');
print_r($getDamagesResult);

echo "\n===== DAMAGE REPORTING TESTING COMPLETED =====\n";
