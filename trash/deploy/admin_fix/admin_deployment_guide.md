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

### 2. Upload Deployment Script

```bash
# Copy the deployment script to the production server
scp /home/senne/projects/uitlenen/final_admin_fix_production.sh user@uitleensysteemfirda.nl:/tmp/
```

### 3. Execute the Deployment Script

SSH into the production server and run the deployment script:

```bash
# SSH into the server
ssh user@uitleensysteemfirda.nl

# Make the script executable
chmod +x /tmp/final_admin_fix_production.sh

# Run the script
sudo -u www-data /tmp/final_admin_fix_production.sh
```

The script will:
- Create backups of all modified files
- Apply fixes to the UserController
- Create the SimpleUserController as a backup solution
- Add health check routes
- Fix middleware syntax in routes
- Clear Laravel cache

### 4. Verify the Deployment

After deployment, verify that everything is working properly:

```bash
# Test the health check endpoint
curl -X GET "https://uitleensysteemfirda.nl/api/admin-health-check"

# Test the admin functionality with an admin token
curl -X GET "https://uitleensysteemfirda.nl/api/users" \
  -H "Authorization: Bearer 5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585"

# Test the simple admin functionality
curl -X GET "https://uitleensysteemfirda.nl/api/simple-users" \
  -H "Authorization: Bearer 5|3GfO6NENaefynHQjYW9RDpyJIId55ZAO1dp0aEd026b1c585"
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

1. **Temporary Fixes**: The current implementation includes:
   - Auto-verification of email addresses instead of sending verification emails
   - Temporary passwords exposed in API responses for testing

2. **Future Improvements**: Once email functionality is properly configured:
   - Remove auto-verification and re-enable email verification
   - Remove temporary password exposure from API responses

## Deployment Checklist

- [ ] Uploaded deployment script to production server
- [ ] Executed deployment script with proper permissions
- [ ] Verified health check endpoint works
- [ ] Verified admin user listing functionality works
- [ ] Verified admin user creation functionality works
- [ ] Monitored logs for any errors
- [ ] Documented deployment in system records

---

Date: June 11, 2025
