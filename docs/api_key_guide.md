# API Key Authentication Guide

This guide explains how to use API keys for authentication when accessing the API.

## What are API Keys?

API keys provide a simple way to authenticate machine-to-machine communication with our API. Unlike user authentication (which uses tokens obtained through login), API keys are long-lived credentials that can be used by external applications or services to access specific API endpoints.

## When to Use API Keys

API keys are ideal for:
- Integration with other systems
- Server-to-server communication
- Automated scripts or cron jobs
- Applications that need to access the API without user interaction

## Managing API Keys

### Creating an API Key

Only administrators can create API keys through the Admin UI or using the command:

```bash
php artisan api:generate-key "Key Name" [--expires="2026-01-01"]
```

Parameters:
- `Key Name`: A descriptive name for the API key (e.g., "Inventory System")
- `--expires`: Optional expiration date for the key

### Listing API Keys

```bash
php artisan api:list-keys
```

### Revoking an API Key

```bash
php artisan api:revoke-key KEY_ID
```

## Using API Keys in Requests

When making requests to API endpoints that support API key authentication, include the API key in the HTTP header:

```
X-API-KEY: your-api-key-here
```

Example using curl:

```bash
curl -H "X-API-KEY: your-api-key-here" https://your-domain.com/api/items/available
```

Example using JavaScript/Fetch:

```javascript
fetch('https://your-domain.com/api/items/available', {
  headers: {
    'X-API-KEY': 'your-api-key-here'
  }
})
.then(response => response.json())
.then(data => console.log(data));
```

## Available API Key Endpoints

The following endpoints can be accessed using API key authentication:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/items/available` | GET | Get a list of all available (not currently loaned) items |
| `/api/lendings/overdue` | GET | Get a list of all overdue loans |

## Security Best Practices

1. **Treat API keys like passwords** - Store them securely and never commit them to source control
2. **Use specific keys for specific purposes** - Create separate API keys for different applications/systems
3. **Set expiration dates** - Consider adding expiration dates to limit the risk if a key is compromised
4. **Revoke unused keys** - Regularly audit and revoke keys that are no longer needed
5. **Use HTTPS** - Always use HTTPS when transmitting API keys

## Troubleshooting

If you receive a 401 Unauthorized response, check:
- The API key is valid and has not expired
- The API key is being sent in the correct header (X-API-KEY)
- The API key has not been revoked
