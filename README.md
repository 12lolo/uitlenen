# 📦 Uitleen-API – Equipment Lending System for Firda

The **Uitleen-API** is a Laravel-based RESTful API designed for managing the lending and tracking of school equipment at Firda. Students can browse available items, while authenticated teachers (admins) can manage lending, returns, damage reports, and categories. The system also includes automated email reminders for due and overdue returns.

---

## 🚀 Features

- 🔍 View categories and items without logging in
- 🔐 Teacher registration and login (Firda email required)
- 📚 Manage lending and returns of items
- 🛠 Damage inspection and registration
- 📬 Automated email reminders
- 🗃 Admin-level category and user management
- 📊 Overviews for due and late items

---

## 📁 Project Structure

- `app/Models` – Eloquent models
- `app/Http/Controllers` – REST API controllers
- `routes/api.php` – API routes
- `database/migrations` – Database structure
- `tests/Feature` – Automated feature tests
- `docs/` – Markdown documentation (functional, technical, testing)

---

## 🧑‍💻 Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourname/uitleen-api.git
   cd uitleen-api
Install dependencies:

bash
Copy
Edit
composer install
npm install && npm run build
Create .env and configure:

bash
Copy
Edit
cp .env.example .env
php artisan key:generate
Set database credentials in .env and run migrations:

bash
Copy
Edit
php artisan migrate
(Optional) Run test suite:

bash
Copy
Edit
php artisan test
🔒 Authentication
Teachers register with a valid Firda email (@firda.nl or @student.firda.nl)

JSON Web Tokens (JWT) are used for login and protected routes

📬 Scheduled Tasks
Daily cron job (schedule:run) triggers automatic email reminders:

24 hours before return deadline

24 hours after overdue

🧪 Tests
Feature tests are located in tests/Feature/. Run with:

bash
Copy
Edit
php artisan test
📄 Documentation
All project documentation is included in /docs/:

functioneel-ontwerp.md

technisch-ontwerp.md

testplan.md

testrapport.md (after testing phase)

📌 Requirements
PHP 8.1+

Laravel 10+

MySQL / MariaDB

Node.js + npm (for frontend build)

Mail server for email functionality

📖 License
This project is for educational purposes under Firda and is not licensed for production use.
