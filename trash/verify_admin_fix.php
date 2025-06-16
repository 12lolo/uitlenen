<?php
// Verify admin functionality fix

$token = "5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585";
$baseUrl = "https://uitleensysteemfirda.nl/api";

function makeRequest($method, $endpoint, $data = null) {
    global $token, $baseUrl;
    
    $ch = curl_init($baseUrl . $endpoint);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Authorization: Bearer ' . $token
    ]);
    
    if ($data && ($method == 'POST' || $method == 'PUT')) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    }
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    return [
        'code' => $httpCode,
        'response' => json_decode($response, true)
    ];
}

echo "Verifying admin functionality fix:\n\n";

// 1. Test getting all users
$result = makeRequest('GET', '/users');
echo "GET /users status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Success! Admin user listing is working.\n";
    echo "Users found: " . count($result['response']) . "\n\n";
} else {
    echo "❌ Error: Admin user listing still not working.\n";
    print_r($result['response']);
    echo "\n";
}

// 2. Test creating a new user
$testEmail = "test" . time() . "@firda.nl";
$result = makeRequest('POST', '/users', [
    'email' => $testEmail,
    'is_admin' => false
]);

echo "POST /users status code: " . $result['code'] . "\n";
if ($result['code'] == 201) {
    echo "✅ Success! Admin user creation is working.\n";
    echo "New user created with email: " . $testEmail . "\n";
    echo "Temporary password: " . ($result['response']['temp_password'] ?? 'Not provided') . "\n";
} else {
    echo "❌ Error: Admin user creation still not working.\n";
    print_r($result['response']);
}
