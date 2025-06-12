# Comprehensive Admin Fix - Server Deployment Guide

## Step 1: Upload Files
Upload the `admin_fix_comprehensive.zip` file to your server using SCP or SFTP:

```bash
scp admin_fix_comprehensive.zip user@uitleensysteemfirda.nl:/tmp/
```

## Step 2: Extract and Deploy on Server
SSH into your server and run these commands:

```bash
# Log in to server
ssh user@uitleensysteemfirda.nl

# Navigate to Laravel project directory
cd /var/www/uitleensysteemfirda.nl

# Create backup
mkdir -p backups/$(date +%Y%m%d)
cp -f app/Http/Controllers/UserController.php backups/$(date +%Y%m%d)/UserController.php.bak
cp -f routes/api.php backups/$(date +%Y%m%d)/api.php.bak

# Extract fix files
unzip -o /tmp/admin_fix_comprehensive.zip -d /tmp/admin_fix/
cp -f /tmp/admin_fix/UserController.php app/Http/Controllers/
cp -f /tmp/admin_fix/api.php routes/
cp -f /tmp/admin_fix/comprehensive_admin_fix.php routes/

# Set proper permissions
chown -R www-data:www-data app/Http/Controllers/
chown -R www-data:www-data routes/
chmod 644 app/Http/Controllers/UserController.php
chmod 644 routes/api.php
chmod 644 routes/comprehensive_admin_fix.php

# Clear Laravel cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Clean up
rm -rf /tmp/admin_fix
rm /tmp/admin_fix_comprehensive.zip
```

## Step 3: Apply the Fix
Use curl to trigger the fix endpoint (requires a valid admin token):

```bash
curl -X GET "https://uitleensysteemfirda.nl/api/comprehensive-admin-fix/fix_admin_june_2025" \
  -H "Authorization: Bearer 5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585" \
  -H "Content-Type: application/json"
```

## Step 4: Verify the Fix
Run the verification script locally:

```bash
php verify_comprehensive_fix.php
```

## Troubleshooting
If issues persist:

1. Check Laravel logs on the server:
   ```bash
   tail -n 100 /var/www/uitleensysteemfirda.nl/storage/logs/laravel-*.log
   ```

2. Ensure the admin middleware is properly registered in app/Http/Kernel.php:
   ```php
   protected $middlewareAliases = [
       // ... other middleware
       'admin' => \App\Http\Middleware\AdminMiddleware::class,
   ];
   ```

3. Test the direct endpoint which bypasses the admin middleware:
   ```
   GET /api/direct-user-test
   ```

4. Check PHP error logs:
   ```bash
   tail -n 100 /var/log/apache2/error.log  # For Apache
   # or
   tail -n 100 /var/log/nginx/error.log    # For Nginx
   ```
