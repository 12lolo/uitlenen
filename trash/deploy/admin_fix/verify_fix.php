<?php
// Verify admin functionality fix on production

$token = "5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585"; // Replace with your admin token
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

echo "===== VERIFYING ADMIN FIX ON PRODUCTION =====\n\n";

// 0. Test health check endpoint (doesn't require auth)
echo "0. Testing health check endpoint...\n";
$result = makeRequest('GET', '/admin-health-check');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Admin routes are being loaded correctly.\n\n";
} else {
    echo "❌ Admin routes might not be loaded correctly.\n\n";
}

// 1. Test direct route with auth
echo "1. Testing direct user test endpoint...\n";
$result = makeRequest('GET', '/direct-user-test');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Direct test route is working.\n";
    echo "Current user: " . json_encode($result['response']['current_user'] ?? 'Not available') . "\n";
    echo "Users: " . count($result['response']['users'] ?? []) . " found\n\n";
} else {
    echo "❌ Direct test route failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

// 2. Test regular admin route
echo "2. Testing regular admin route (GET /users)...\n";
$result = makeRequest('GET', '/users');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Regular admin route is working.\n";
    echo "Users found: " . count($result['response'] ?? []) . "\n\n";
} else {
    echo "❌ Regular admin route failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

// 3. Test simple admin route
echo "3. Testing simple admin route (GET /simple-users)...\n";
$result = makeRequest('GET', '/simple-users');
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 200) {
    echo "✅ Simple admin route is working.\n";
    echo "Users found: " . count($result['response']['users'] ?? []) . "\n\n";
} else {
    echo "❌ Simple admin route failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

// 4. Test user creation
$testEmail = "test" . time() . "@firda.nl";
echo "4. Testing user creation (POST /users with email: $testEmail)...\n";
$result = makeRequest('POST', '/users', [
    'email' => $testEmail,
    'is_admin' => false
]);
echo "Status code: " . $result['code'] . "\n";
if ($result['code'] == 201) {
    echo "✅ User creation is working.\n";
    echo "User ID: " . ($result['response']['user']['id'] ?? 'Not available') . "\n";
    echo "Temp password: " . ($result['response']['temp_password'] ?? 'Not provided') . "\n\n";
} else {
    echo "❌ User creation failed.\n";
    if (isset($result['response']['message'])) {
        echo "Error: " . $result['response']['message'] . "\n";
    }
    echo "\n";
}

echo "===== VERIFICATION COMPLETED =====\n";
echo "Summary:\n";
$passed = 0;
$failed = 0;

// Report on health check
if (isset($result) && $result['code'] == 200) { $passed++; } else { $failed++; }

// Reset result to avoid confusion
unset($result);

echo "Tests passed: " . $passed . "\n";
echo "Tests failed: " . $failed . "\n";

if ($failed > 0) {
    echo "\nIf any tests failed, check server logs for more details:\n";
    echo "Log location: /var/www/uitleensysteemfirda.nl/storage/logs/laravel-*.log\n";
}
