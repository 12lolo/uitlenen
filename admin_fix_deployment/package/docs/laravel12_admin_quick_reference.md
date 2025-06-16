# Laravel 12 Admin Middleware Quick Reference

## Key Changes Made

- Authentication using `Auth::check()` instead of `auth()->check()`
- Authorization checks directly in controller methods
- Dedicated admin routes in separate files
- Comprehensive test endpoints for verification

## Common Issues & Solutions

### 403 Forbidden when accessing admin endpoints

**Possible causes:**
- User not authenticated
- User not marked as admin in database
- Auth facades not properly imported
- Laravel cache needs clearing

**Solutions:**
- Verify user has `is_admin = true` in database
- Run `php artisan optimize:clear`
- Check auth token is valid and properly formatted
- Use the `/api/admin-direct-test` endpoint for diagnostics

### 500 Internal Server Error

**Possible causes:**
- Middleware resolution issues
- Auth helper function errors
- Undefined method calls

**Solutions:**
- Check Laravel logs at `storage/logs/laravel-*.log`
- Verify Auth facade is imported in controller/middleware
- Run the comprehensive fix script again
- Test with direct test endpoints to isolate issue

## Testing Commands

Test basic authentication:
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" https://uitleensysteemfirda.nl/api/auth-check-test
```

Test admin check:
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" https://uitleensysteemfirda.nl/api/admin-direct-test
```

Test user creation:
```bash
curl -X POST -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"email":"new_teacher@firda.nl","is_admin":false}' \
  https://uitleensysteemfirda.nl/api/users
```

Run comprehensive test:
```bash
./test_admin_endpoints.sh YOUR_TOKEN
```

## Important Files

- **UserController**: `/app/Http/Controllers/UserController.php`
- **Admin Middleware**: `/app/Http/Middleware/AdminMiddleware.php`
- **Admin Routes**: `/routes/admin.php`
- **Test Endpoints**: `/routes/admin_test_routes.php`
- **Kernel Middleware**: `/app/Http/Kernel.php`

## Laravel 12 Authentication Best Practices

1. Always use full facades (`Illuminate\Support\Facades\Auth`)
2. Prefer controller-level authorization over middleware for complex logic
3. Use dedicated route files for administrative functions
4. Include test endpoints for critical functionality
5. Implement comprehensive logging for debugging
