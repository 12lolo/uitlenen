# Admin Functionality Fix - Deployment Guide

This guide provides step-by-step instructions for deploying the admin functionality fix to the production server.

## Prerequisites

- SSH access to the production server
- Sufficient permissions to modify files and restart services
- A backup of the current production environment

## Deployment Steps

### 1. Prepare for Deployment

Before deploying to production, ensure you have:

- ✅ Verified the fix works locally
- ✅ Created proper backups
- ✅ Tested the admin functionality comprehensively
- ✅ Removed temporary password display from UserController

### 2. Upload and Execute the Final Deployment Script

```bash
# Make the deployment script executable
chmod +x /home/senne/projects/uitlenen/final_deployment.sh

# Run the deployment script
/home/senne/projects/uitlenen/final_deployment.sh
```

The script will:
- Upload the updated UserController.php (with password display removed)
- Upload and execute the comprehensive cleanup script
- Upload the verification script
- Clear all Laravel caches
- Set proper file permissions

### 4. Verify the Deployment

After deployment, verify that everything is working properly:

```bash
# Run the verification script
./verify_admin_functionality.sh

# Or test individual endpoints manually:
# Test the health check endpoint
curl -X GET "https://uitleensysteemfirda.nl/api/admin-health-check"

# Test the admin functionality with an admin token
curl -X GET "https://uitleensysteemfirda.nl/api/users" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"

# Test user creation (no longer displays password)
curl -X POST "https://uitleensysteemfirda.nl/api/users" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@firda.nl","is_admin":false}'
```

### 5. Monitor for Issues

After deployment, monitor the application logs for any issues:

```bash
# Check Laravel logs
tail -f /var/www/uitleensysteemfirda.nl/storage/logs/laravel-*.log

# Check web server error logs
tail -f /var/log/nginx/error.log  # For Nginx
# or
tail -f /var/log/apache2/error.log  # For Apache
```

### 6. Rollback Plan (If Needed)

If issues arise, you can restore from the backups created by the deployment script:

```bash
# Find the backup directory
ls -la /var/www/uitleensysteemfirda.nl/backups/

# Restore from backup
cp /var/www/uitleensysteemfirda.nl/backups/admin_fix_YYYYMMDD_HHMMSS/UserController.php.bak \
   /var/www/uitleensysteemfirda.nl/app/Http/Controllers/UserController.php
cp /var/www/uitleensysteemfirda.nl/backups/admin_fix_YYYYMMDD_HHMMSS/api.php.bak \
   /var/www/uitleensysteemfirda.nl/routes/api.php

# Clear cache after rollback
cd /var/www/uitleensysteemfirda.nl
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

## Additional Notes

1. **Security Improvements**: ✅ COMPLETED
   - Removed temporary password display from UserController
   - Admin authorization properly enforced at controller level
   - All test endpoints removed from production with cleanup script
   - Proper file permissions set

2. **Future Improvements**: 
   - Re-enable email verification once email functionality is properly configured
   - Implement a more robust user invitation system
   - Add more comprehensive error handling throughout the application

## Deployment Checklist

- [ ] Made a backup of the production database
- [ ] Made backups of critical files (UserController, Kernel.php, api.php)
- [ ] Executed final deployment script with proper permissions
- [ ] Verified health check endpoint works
- [ ] Verified admin user listing functionality works
- [ ] Verified admin user creation functionality works (without password display)
- [ ] Verified cleanup script removed all temporary files
- [ ] Monitored logs for any errors
- [ ] Documented deployment in system records

## Rollback Plan

If issues arise after deployment, use this rollback procedure:

```bash
# SSH into the production server
ssh -p 65002 u540587252@92.113.19.61

# Change to the application directory
cd /home/u540587252/domains/uitleensysteemfirda.nl/public_html

# Restore from the backups created during deployment
cp backup/UserController.php.bak app/Http/Controllers/UserController.php
cp backup/Kernel.php.bak app/Http/Kernel.php
cp backup/api.php.bak routes/api.php

# Clear all caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan optimize:clear
```

---

Updated: June 11, 2025
