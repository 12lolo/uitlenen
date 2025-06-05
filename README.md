Certainly! Here's your **updated and final `README.md`** file for your Laravel Uitleen-API project, including the correct GitHub URL and clean formatting:
# Firda Uitleensysteem API

## Beschrijving
Dit is een API voor het beheren van uitleenmateriaal bij Firda. Het systeem maakt het mogelijk om apparatuur uit te lenen, te retourneren en de status bij te houden.

## Installatie

```bash
# Kloon de repository
git clone [repository-url]

# Ga naar de projectmap
cd [project-map]

# Installeer de dependencies
composer install

# Kopieer het .env bestand
cp .env.example .env

# Genereer een app key
php artisan key:generate

# Configureer de database in .env

# Voer de migraties uit
php artisan migrate

# Start de server
php artisan serve
```

## Foutoplossing

### Database tabellen ontbreken

Als je een foutmelding krijgt over ontbrekende tabellen (zoals 'personal_access_tokens'), controleer dan of alle migraties correct zijn uitgevoerd:

```bash
# Bekijk de status van migraties
php artisan migrate:status

# Voer alle migraties uit
php artisan migrate

# Of voer opnieuw alle migraties uit (dit verwijdert bestaande data)
php artisan migrate:fresh
```

## ⚠️ Troubleshooting

### Missing Tables Error

If you encounter an error related to missing tables (like `personal_access_tokens`), run the migrations:

```bash
php artisan migrate
```

If that doesn't work, try:

```bash
php artisan migrate:fresh
```

> Note: `migrate:fresh` will drop all tables and recreate them.

## Functionaliteiten

- Beheer van uitleenbare items en categorieën
- Uitleenregistratie en retournering
- Automatische e-mailherinneringen
- Schaderapportage
- Gebruikersbeheer met rollen

Raadpleeg de documentatie in `/documentation/functioneel-ontwerp.md` voor meer details.
````markdown
# 📦 Uitleen-API – Firda

A Laravel-based lending system that allows students to view equipment and teachers (admins) to manage loans, returns, damage reports, and reminders. Built with role-based access, email notifications, and RESTful endpoints.

## 🔗 Project Repository

```bash
git clone https://github.com/12lolo/uitlenen.git
````

---

## 📚 Documentation

All documentation is available in the `/docs` folder and includes:

* `projectplan.md` – Project summary, planning and objectives
* `functioneel-ontwerp.md` – Functional design including user roles and modules
* `technisch-ontwerp.md` – Technical system design, database, and architecture
* `testplan.md` – Test plan and test cases
* `testrapport.md` – Will be created after testing phase

---

## 👥 Roles

* **Student** (not logged in): Can view available equipment by category
* **Docent** (logged in): Can manage categories, items, loans, damage reports, and view other users

> Only email addresses ending in `@firda.nl` or `@student.firda.nl` can register
> Only a logged-in docent (admin) can add other docents

---

## 🛠 Features

* JWT-based registration & login system
* Role-based access (student vs docent)
* Equipment categories & item listings
* Loan registration and return with optional damage logging
* Email reminders before and after loan return dates
* RESTful API structure with token auth
* Modular and maintainable codebase

---

## 🧱 Tech Stack

* Laravel 11 (PHP 8.3)
* Sanctum (for authentication)
* MySQL or SQLite (local)
* Laravel Scheduler (for emails)
* Mail (configured in `.env`)

---

## 🚀 Installation

1. Clone the repository

   ```bash
   git clone https://github.com/12lolo/uitlenen.git
   cd uitlenen
   ```

2. Install dependencies

   ```bash
   composer install
   npm install && npm run build
   ```

3. Set up your environment

   ```bash
   cp .env.example .env
   php artisan key:generate
   ```

4. Configure your `.env` (database, mail, etc.)

5. Run migrations

   ```bash
   php artisan migrate
   ```

6. Run the local server

   ```bash
   php artisan serve
   ```

---

## 🧪 Running Tests

```bash
php artisan test
```

---

## 📬 Mail Setup (Development)

For testing email reminders, use a service like [Mailtrap](https://mailtrap.io) and update your `.env`:

```env
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=your_mailtrap_username
MAIL_PASSWORD=your_mailtrap_password
MAIL_FROM_ADDRESS="noreply@firda.nl"
MAIL_FROM_NAME="Uitleen API"
```

---

## 📅 Task Scheduler

Add this cron to your server to send daily email reminders:

```bash
* * * * * php /path/to/artisan schedule:run >> /dev/null 2>&1
```

---

## 📄 License

This project is for educational use by students at Firda.

---

## ✍️ Author

**Senne Visser**
[GitHub: 12lolo](https://github.com/12lolo)
