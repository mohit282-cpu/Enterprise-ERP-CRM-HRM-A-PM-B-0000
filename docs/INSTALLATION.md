# Local Installation Guide

1. **Requirements:** PHP 8.3+, MySQL 8.0+, Composer.
2. **Clone the Repo:** `git clone ...`
3. **Dependencies:** Run `composer install` to download PHPUnit and dompdf (Phase 2).
4. **Database Setup:** 
   - Create a MySQL database.
   - Run the PowerShell migration script `.\run_migrations.ps1` to execute all files in `database/migrations/` sequentially.
5. **Local Server:** 
   - Point your XAMPP/Apache document root to the project folder.
   - Or run PHP's built-in server: `php -S localhost:8000 -t public/`
