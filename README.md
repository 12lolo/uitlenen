Certainly! Here's your **updated and final `README.md`** file for your Laravel Uitleen-API project, including the correct GitHub URL and clean formatting:

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
