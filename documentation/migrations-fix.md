# Fixing Migrations for Sanctum Authentication

If you encounter the error `Table 'uitlenen.personal_access_tokens' doesn't exist`, follow these steps to fix it:

1. First, ensure your migration file is correct by checking `database/migrations/2025_06_05_100000_create_sanctum_tokens_table.php`

2. Run the migrations:

```bash
php artisan migrate
```

3. If that doesn't work, check if there are issues with your migration files:

```bash
php artisan migrate:status
```

4. As a last resort, you can completely reset the migrations (this will delete all data):

```bash
php artisan migrate:fresh
```

5. If you're still having trouble, ensure your database user has the correct permissions to create tables.

After running the migration, you should be able to log in successfully.
