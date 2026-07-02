# Installation Guide

This comprehensive guide covers the installation of **Sovryx OS** for both local development and production environments.

---

## 📋 System Requirements

Ensure your server meets the following requirements before proceeding:

- **Operating System:** Ubuntu 22.04 LTS / 20.04 LTS, CentOS, Debian, or Windows (via WSL/XAMPP/Laragon).
- **Web Server:** Apache 2.4+ or Nginx.
- **PHP:** Version 8.3 or higher.
- **Database:** MySQL 8.0+ or MariaDB 10.4+.
- **Composer:** Dependency Manager for PHP (latest v2.x).
- **PHP Extensions:**
  - `pdo_mysql` (Database connection)
  - `mbstring` (Multibyte string support)
  - `openssl` (Encryption)
  - `json` (JSON processing)
  - `curl` (API requests)
  - `gd` or `imagick` (Image processing)
  - `xml`, `zip`, `intl`

---

## 🛠 1. Initial Server Setup

### Update Packages (Ubuntu/Debian)
```bash
sudo apt update && sudo apt upgrade -y
```

### Install PHP 8.3 and Extensions
```bash
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install php8.3 php8.3-cli php8.3-fpm php8.3-mysql php8.3-curl php8.3-mbstring php8.3-xml php8.3-zip php8.3-gd php8.3-intl -y
```

### Install MySQL 8
```bash
sudo apt install mysql-server -y
sudo mysql_secure_installation
```

### Install Composer
```bash
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

---

## 📥 2. Project Installation

### Clone the Repository
Clone the project into your web root (e.g., `/var/www/`):
```bash
cd /var/www/
git clone https://github.com/sovryxtech/sovryx-os.git
cd sovryx-os
```

### Install Dependencies
Run Composer to install all required PHP libraries:
```bash
composer install --optimize-autoloader --no-dev
```
*(Note: Remove `--no-dev` if you are setting up a local development environment).*

---

## ⚙️ 3. Configuration

### Environment Variables
Copy the example environment file:
```bash
cp .env.example .env
```

Edit the `.env` file (`nano .env`) and configure your settings:
```ini
APP_NAME="Sovryx OS"
APP_ENV=production          # Set to 'local' for development
APP_URL=https://app.yourdomain.com
APP_DEBUG=false             # MUST be false in production

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=sovryx_os
DB_USERNAME=root
DB_PASSWORD=your_secure_db_password

# Email Configuration (SMTP)
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailgun.org
MAIL_PORT=587
MAIL_USERNAME=postmaster@yourdomain.com
MAIL_PASSWORD=your_smtp_password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@yourdomain.com
MAIL_FROM_NAME="${APP_NAME}"
```

---

## 🗄 4. Database Setup

### Create Database
Log into MySQL:
```bash
mysql -u root -p
```
Run the following SQL commands:
```sql
CREATE DATABASE sovryx_os CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'sovryx_user'@'localhost' IDENTIFIED BY 'your_secure_db_password';
GRANT ALL PRIVILEGES ON sovryx_os.* TO 'sovryx_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```
*(Ensure you update your `.env` file with these new credentials).*

### Run Migrations & Seeders
Build the database schema and populate initial roles/admin accounts:
```bash
php sovryx migrate
php sovryx db:seed
```
*(Default Admin Login: admin@sovryxtech.com / password)*

---

## 📁 5. Folder Permissions

The web server needs write access to specific directories for file uploads, PDF generation, and caching.

```bash
sudo chown -R www-data:www-data /var/www/sovryx-os
sudo find /var/www/sovryx-os -type f -exec chmod 644 {} \;
sudo find /var/www/sovryx-os -type d -exec chmod 755 {} \;

# Grant write permissions to specific folders
sudo chmod -R 775 /var/www/sovryx-os/public/uploads
sudo chmod -R 775 /var/www/sovryx-os/storage
```

---

## 🌐 6. Web Server Configuration

### Apache
Enable `mod_rewrite`:
```bash
sudo a2enmod rewrite
```
Create a VirtualHost file `/etc/apache2/sites-available/sovryx.conf`:
```apache
<VirtualHost *:80>
    ServerName app.yourdomain.com
    DocumentRoot /var/www/sovryx-os/public

    <Directory /var/www/sovryx-os/public>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/sovryx_error.log
    CustomLog ${APACHE_LOG_DIR}/sovryx_access.log combined
</VirtualHost>
```
Enable the site and restart Apache:
```bash
sudo a2ensite sovryx.conf
sudo systemctl restart apache2
```

### Nginx (Alternative)
Create a server block `/etc/nginx/sites-available/sovryx`:
```nginx
server {
    listen 80;
    server_name app.yourdomain.com;
    root /var/www/sovryx-os/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
```
Enable the site and restart Nginx:
```bash
sudo ln -s /etc/nginx/sites-available/sovryx /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

---

## 🔒 7. SSL Configuration (Production)
Secure your application with Let's Encrypt:
```bash
sudo apt install certbot python3-certbot-apache # or python3-certbot-nginx
sudo certbot --apache -d app.yourdomain.com
```

---

## ⏱ 8. Cron Jobs
To enable automated tasks (hosting renewal checks, invoice recurring generation, database backups), add the following to your system's crontab:

```bash
crontab -e
```
Add this line (runs every minute):
```bash
* * * * * cd /var/www/sovryx-os && php sovryx schedule:run >> /dev/null 2>&1
```

---
**Installation is Complete!** You can now access Sovryx OS at `https://app.yourdomain.com`.
