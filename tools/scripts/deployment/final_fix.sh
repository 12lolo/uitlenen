#!/bin/bash

# SSH connection details
SSH_USER="u540587252"
SSH_HOST="92.113.19.61"
SSH_PORT="65002"

# Connect to SSH and run commands
ssh -p $SSH_PORT $SSH_USER@$SSH_HOST << 'EOF'
cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html

# Final fix for Laravel web application
echo "### Final deployment fix ###"

# Update .env file to use file session driver
sed -i "s/SESSION_DRIVER=database/SESSION_DRIVER=file/g" .env

# Fix path to bootstrap/app.php in index.php
cat > index.php << 'ENDPHP'
<?php

/**
 * Laravel - A PHP Framework For Web Artisans
 */

define('LARAVEL_START', microtime(true));

/*
|--------------------------------------------------------------------------
| Register The Auto Loader
|--------------------------------------------------------------------------
|
| Composer provides a convenient, automatically generated class loader for
| this application. We just need to utilize it! We'll simply require it
| into the script here so we don't need to manually load our classes.
|
*/

require __DIR__.'/vendor/autoload.php';

/*
|--------------------------------------------------------------------------
| Turn On The Lights
|--------------------------------------------------------------------------
|
| We need to illuminate PHP development, so let us turn on the lights.
| This bootstraps the framework and gets it ready for use, then it
| will load up this application so that we can run it and send
| the responses back to the browser and delight our users.
|
*/

$app = require_once __DIR__.'/bootstrap/app.php';

/*
|--------------------------------------------------------------------------
| Run The Application
|--------------------------------------------------------------------------
|
| Once we have the application, we can handle the incoming request using
| the application's HTTP kernel. Then, we will send the response back
| to this client's browser, allowing them to enjoy our application.
|
*/

$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

$response = $kernel->handle(
    $request = Illuminate\Http\Request::capture()
);

$response->send();

$kernel->terminate($request, $response);
ENDPHP

# Clear all caches
php artisan view:clear
php artisan route:clear
php artisan config:clear
php artisan cache:clear

# Enable debug mode temporarily
sed -i "s/APP_DEBUG=false/APP_DEBUG=true/g" .env

echo "### Deployment fixed ###"
echo "Your application should now be accessible at https://uitleensysteemfirda.nl"
EOF
