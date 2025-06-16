# Admin Functionality Fix - Manual Deployment

If the automatic deployment script doesn't work for any reason, follow these manual steps:

## 1. Copy Files to the Server

Upload these files to the correct locations:

- `UserController.php` → `/var/www/uitleensysteemfirda.nl/app/Http/Controllers/`
- `SimpleUserController.php` → `/var/www/uitleensysteemfirda.nl/app/Http/Controllers/`
- `admin_health_check.php` → `/var/www/uitleensysteemfirda.nl/routes/`

## 2. Update Routes File

Edit `/var/www/uitleensysteemfirda.nl/routes/api.php` and:

1. Fix middleware syntax by replacing:
   ```php
   Route::middleware('admin')->group(function () {
   ```
   with:
   ```php
   Route::middleware(['admin'])->group(function () {
   ```

2. Add the health check routes include at the end of the file:
   ```php
   // Include the admin health check routes
   require __DIR__.'/admin_health_check.php';
   ```

## 3. Clear Laravel Cache

Run these commands:

```bash
cd /var/www/uitleensysteemfirda.nl
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

## 4. Verify the Fix

Run the verification script:

```bash
php verify_fix.php
```

## Support

If you encounter any issues, check the Laravel logs at:
`/var/www/uitleensysteemfirda.nl/storage/logs/laravel-*.log`
