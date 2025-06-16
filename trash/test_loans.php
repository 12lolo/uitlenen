<?php
// A simple PHP script to test loan functionality with the API

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

echo "===== TESTING LOAN FUNCTIONALITY =====\n\n";

echo "1. Getting all available items...\n";
$getItemsResult = makeRequest('GET', '/items');
// Find an available item to loan
$availableItem = null;
foreach ($getItemsResult['response'] as $item) {
    if (isset($item['status']) && $item['status'] == 'available') {
        $availableItem = $item;
        break;
    }
}

if (!$availableItem) {
    die("No available items found. Cannot continue testing loans.\n");
}

echo "Found available item: {$availableItem['title']} (ID: {$availableItem['id']})\n\n";

echo "2. Creating a new loan...\n";
$tomorrow = date('Y-m-d', strtotime('+1 day'));
$createLoanResult = makeRequest('POST', '/lendings', [
    'item_id' => $availableItem['id'],
    'student_name' => 'Test Student',
    'student_email' => 'test.student@student.firda.nl',
    'due_date' => $tomorrow,
    'notes' => 'Test loan created via API'
]);

print_r($createLoanResult);

// Extract the loan ID for later use
$loanId = $createLoanResult['response']['loan']['id'] ?? null;

if (!$loanId) {
    die("Failed to create loan. Cannot continue testing.\n");
}

echo "\n3. Testing student email validation (should fail with non-student email)...\n";
$invalidEmailTest = makeRequest('POST', '/lendings', [
    'item_id' => $availableItem['id'],
    'student_name' => 'Invalid Email Test',
    'student_email' => 'invalid@gmail.com',
    'due_date' => $tomorrow,
    'notes' => 'This should fail because email is not @student.firda.nl'
]);

print_r($invalidEmailTest);

echo "\n4. Getting all loans...\n";
$getLoansResult = makeRequest('GET', '/lendings');
print_r($getLoansResult);

echo "\n5. Returning the test loan (ID: $loanId)...\n";
$returnLoanResult = makeRequest('POST', "/lendings/$loanId/return", [
    'return_notes' => 'Returned during API testing'
]);

print_r($returnLoanResult);

echo "\n6. Checking loan status (due today and overdue)...\n";
$loanStatusResult = makeRequest('GET', '/lendings/status');
print_r($loanStatusResult);

echo "\n===== LOAN FUNCTIONALITY TESTING COMPLETED =====\n";
