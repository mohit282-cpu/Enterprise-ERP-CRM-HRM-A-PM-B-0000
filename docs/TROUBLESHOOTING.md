# Troubleshooting Guide

This guide helps administrators diagnose and resolve common issues encountered while running **Sovryx OS**.

---

## 🚨 1. "White Screen of Death" or HTTP 500 Error

**Symptoms:** 
You navigate to the application, and the screen is completely blank, or the browser shows a standard "500 Internal Server Error".

**Causes & Solutions:**
1. **Permissions Issue:** The `storage/` or `public/uploads/` directories are not writable by the web server.
   - *Fix:* Run `sudo chmod -R 775 storage/` and `sudo chown -R www-data:www-data storage/`.
2. **Missing Dependencies:** Composer packages were not installed.
   - *Fix:* Run `composer install --no-dev`.
3. **Check the Logs:** To see the exact PHP error, open `storage/logs/system.log` or check your server's PHP error log (`/var/log/apache2/error.log`).

---

## 📧 2. Emails are Not Sending

**Symptoms:**
Invoices are not reaching clients, or password reset emails fail to send.

**Causes & Solutions:**
1. **Invalid SMTP Credentials:** Check your `.env` file. Ensure `MAIL_HOST`, `MAIL_PORT`, `MAIL_USERNAME`, and `MAIL_PASSWORD` are correct.
2. **Port Blocked:** Some hosting providers (like DigitalOcean or AWS) block port 25 or 587 by default to prevent spam.
   - *Fix:* Use port 465 (with `MAIL_ENCRYPTION=ssl`) or contact your host to unblock the port. Use a dedicated transactional email service like Mailgun, Postmark, or SendGrid.
3. **Queue Worker Not Running:** If emails are queued, ensure your cron job is executing `php sovryx schedule:run` every minute.

---

## 📄 3. PDF Invoices are Failing to Generate

**Symptoms:**
Clicking "Download PDF" results in a timeout or an error stating "Dompdf Exception".

**Causes & Solutions:**
1. **Missing PHP Extensions:** Dompdf requires the `gd` (or `imagick`) and `mbstring` extensions.
   - *Fix:* Run `sudo apt install php8.3-gd php8.3-mbstring` and restart your web server.
2. **Font Directory Not Writable:** Dompdf needs to write cached fonts to the storage folder.
   - *Fix:* Ensure `/storage/fonts/` exists and has `775` permissions.

---

## 🗄 4. Database Connection Errors

**Symptoms:**
"PDOException: SQLSTATE[HY000] [1045] Access denied for user".

**Causes & Solutions:**
1. **Incorrect `.env` Settings:** Verify `DB_DATABASE`, `DB_USERNAME`, and `DB_PASSWORD`. Note that special characters in passwords might need to be wrapped in quotes (e.g., `DB_PASSWORD="my#secure!password"`).
2. **MySQL Server Down:** Check if the database service is running: `sudo systemctl status mysql`.

---

## 🔐 5. Locked out of Admin Account

**Symptoms:**
You forgot the Super Admin password and cannot log in.

**Causes & Solutions:**
Run the built-in CLI command to forcefully reset the password from the server terminal:
```bash
php sovryx user:reset-password admin@yourdomain.com
```
The console will output a newly generated temporary password.

---

## 💬 Getting Further Help

If your issue is not listed here:
1. Check the [GitHub Issues](#) tracker to see if it's a known bug.
2. Review the application logs in `storage/logs/`.
3. Open a support ticket on the [Sovryx Tech Support Desk](#) (for enterprise license holders).
