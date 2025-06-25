# API Key Implementation Summary

## Features Implemented

### 1. Database Structure
- Created an `ApiKey` model with fields for name, key, active status, and expiration date
- Created a migration to add the `api_keys` table to the database

### 2. Authentication Middleware
- Created the `ApiKeyMiddleware` to validate API keys in request headers
- Registered the middleware as 'api.key' in the HTTP kernel

### 3. Management Commands
- `api:generate-key` - Generates a new API key with optional expiration date
- `api:list-keys` - Lists all API keys in the system
- `api:revoke-key` - Revokes (deactivates) an API key

### 4. API Endpoints
Added API key protected endpoints:
- `GET /api/items/available` - Gets items that are not currently loaned out
- `GET /api/lendings/overdue` - Gets loans that are past their due date

### 5. Documentation
- Created a comprehensive API key guide in `docs/api_key_guide.md`
- Updated the API reference documentation to include API key information
- Created sample scripts to demonstrate API usage:
  - `tools/api_key_test.sh` - Bash script for testing API endpoints
  - `tools/api_key_client.php` - PHP client for API key authentication

## How to Use

### For Administrators

1. Generate a new API key:
   ```
   php artisan api:generate-key "Integration Name" [--expires="2026-01-01"]
   ```

2. List all API keys:
   ```
   php artisan api:list-keys
   ```

3. Revoke an API key:
   ```
   php artisan api:revoke-key KEY_ID
   ```

### For API Consumers

Include the API key in the HTTP header:
```
X-API-KEY: your-api-key-here
```

## Security Considerations

- API keys are stored securely in the database
- API keys are never displayed in full after initial generation (only first 8 characters)
- Keys can be set to expire automatically
- Keys can be revoked at any time
- Only administrators can manage API keys

## Future Enhancements

Potential enhancements for the future:
- Add permission scopes to API keys (limit which endpoints each key can access)
- Add rate limiting specific to API keys
- Add logging for API key usage
- Create a web interface for managing API keys
