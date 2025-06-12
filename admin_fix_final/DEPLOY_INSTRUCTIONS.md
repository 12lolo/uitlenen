# Laravel 12 Admin Fix Deployment Instructions

## Overview
This package fixes the 500 Internal Server Error occurring in the admin functionality, specifically related to Laravel 12 middleware resolution and administrator authorization issues.

## Deployment Steps

### 1. Backup Files
First, backup these files on your production server:
```bash
cp app/Http/Controllers/UserController.php app/Http/Controllers/UserController.php.bak
cp app/Http/Middleware/AdminMiddleware.php app/Http/Middleware/AdminMiddleware.php.bak
cp routes/api.php routes/api.php.bak
```

### 2. Deploy Files
Copy the files from this package to your Laravel installation:
```bash
cp -R * /path/to/your/laravel/app/
```

### 3. Clear Laravel Cache
```bash
cd /path/to/your/laravel/app
php artisan optimize:clear
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

### 4. Verify Deployment
Check that the following endpoints work:
- `GET /api/admin-health-check` - Should return a 200 OK
- `GET /api/users` (with admin token) - Should return a list of users

## Troubleshooting
If you encounter issues:
1. Check the Laravel logs: `tail -f storage/logs/laravel*.log`
2. Make sure the right files were copied
3. Ensure the Laravel cache was cleared properly

## Rollback
In case of problems, restore the backup files:
```bash
cp app/Http/Controllers/UserController.php.bak app/Http/Controllers/UserController.php
cp app/Http/Middleware/AdminMiddleware.php.bak app/Http/Middleware/AdminMiddleware.php
cp routes/api.php.bak routes/api.php
```
