# Firda Lending System API

A RESTful API for managing loanable equipment at Firda. The system supports lending and returning items, tracking status, sending reminders, recording damage, and managing users/roles.

---

## Features

- **Items & Categories:** Create and manage equipment and categories.
- **Loans & Returns:** Register loans, return items, track due dates and statuses.
- **Email Reminders:** Automatic reminders before/after return dates.
- **Damage Reports:** Record and review damage on returned items.
- **Users & Roles:** Role-based access (students vs. teachers/admins).
- **Access Policy:** Only email addresses ending with `@firda.nl` or `@student.firda.nl` can register.

---

## Tech Stack

- **Framework:** Laravel 11 (PHP 8.3)
- **Auth:** Laravel Sanctum (token-based)
- **Database:** MySQL (or SQLite for local development)
- **Scheduler/Mail:** Laravel Scheduler & Mail (configure in `.env`)

---

## Installation

```bash
# Clone the repository
git clone https://github.com/12lolo/uitlenen.git
cd uitlenen

# Install dependencies
composer install

# (Optional if using a frontend build)
npm install && npm run build

# Environment
cp .env.example .env
php artisan key:generate

# Configure your .env (database, mail, etc.)

# Migrate and (optionally) seed
php artisan migrate
php artisan db:seed

# Run the local server
php artisan serve
```

---

## Deployment

The repository includes helper scripts for production:

```bash
# Deploy to production
./deploy_production.sh

# Clean up the production server
./cleanup_production.sh

# Maintenance helper for common tasks
./maintenance.sh
```

See `DEPLOYMENT.md` for detailed deployment steps and server configuration.

**Scheduler (cron):** add this to run scheduled tasks (reminders, etc.):

```bash
* * * * * php /path/to/artisan schedule:run >> /dev/null 2>&1
```

---

## Troubleshooting

### “Missing tables” (e.g., `personal_access_tokens`)
This usually means migrations haven’t run or completed.

```bash
# Check migration status
php artisan migrate:status

# Run pending migrations
php artisan migrate
```

If needed (⚠️ drops all tables):

```bash
php artisan migrate:fresh
```

> Note: `migrate:fresh` will remove all data.

---

## API Overview

- **Authentication:** Token-based via Sanctum.
- **Endpoints:** CRUD for categories, items, loans, damage reports, and users.
- **Reminders:** Scheduled jobs send due/overdue emails.

(See route and controller implementations for exact endpoints and request/response formats.)

---

## Roles

- **Student (not logged in):** Browse available equipment by category.
- **Teacher/Admin (logged in):** Manage categories, items, loans, damage reports, and users.

> Only `@firda.nl` or `@student.firda.nl` email domains can register.  
> Only a logged-in teacher/admin can grant admin rights to others.

---

## Documentation

Project documentation lives in the `/docs` folder:

- `projectplan.md` — Project summary, planning, objectives  
- `functioneel-ontwerp.md` — Functional design (roles, modules, flows)  
- `technisch-ontwerp.md` — Technical design (architecture, DB schema)  
- `testplan.md` — Test plan and scenarios  
- `testrapport.md` — Test report (created after testing)

---

## Tests

```bash
php artisan test
```

---

## License

This project is for educational use by students at Firda.

---

## Author

**Senne Visser**  
GitHub: [12lolo](https://github.com/12lolo)
