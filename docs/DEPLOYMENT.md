# Deployment Guide & DevOps

This guide outlines the best practices for deploying **Sovryx OS** into a high-availability production environment. It covers Continuous Integration/Continuous Deployment (CI/CD), monitoring, and release management.

---

## 🚀 1. Production Server Architecture

For a scalable enterprise deployment, we recommend decoupling services:

1. **Web Node(s):** Runs Nginx/Apache and PHP 8.3-FPM. (Can be horizontally scaled behind a Load Balancer).
2. **Database Node:** Managed MySQL 8 (e.g., AWS RDS, DigitalOcean Managed DB) for automated backups and high availability.
3. **Storage:** Cloud object storage (e.g., AWS S3) for uploaded files and documents to keep web nodes stateless.

---

## ⚙️ 2. CI/CD Pipeline (GitHub Actions)

We utilize GitHub Actions to automate testing and deployment, ensuring code quality and zero-downtime releases.

### Automated Testing (CI)
On every push to `develop` and `main`:
1. Code checkout.
2. Install Composer dependencies (`composer install --no-dev`).
3. Run PHP CodeSniffer for PSR-12 compliance.
4. Run PHPUnit (Unit and Integration tests).
5. If any step fails, the workflow halts, and the team is notified.

### Automated Deployment (CD)
On a successful push to `main` (and passing tests):
1. The deployment script connects to the production server via SSH.
2. Clones the latest code into a new timestamped release folder.
3. Runs database migrations (`php sovryx migrate --force`).
4. Updates the symlink (e.g., `/var/www/sovryx-os/current`) to point to the new release folder.
5. Reloads PHP-FPM and Nginx.

*This symlink approach ensures **Zero-Downtime Deployments**.*

---

## ⏪ 3. Rollback Strategy

If a critical error is discovered immediately post-deployment:

1. Connect to the production server.
2. Point the `current` symlink back to the previous release folder.
3. Reload PHP-FPM.
```bash
ln -sfn /var/www/sovryx-os/releases/20231010120000 /var/www/sovryx-os/current
sudo systemctl reload php8.3-fpm
```
*(Note: Database rollbacks require careful manual intervention depending on the migration executed).*

---

## 📈 4. Monitoring & Logging

### Application Logging
- All internal application errors, exceptions, and API failures are logged in `storage/logs/system.log`.
- Log files are rotated daily to prevent disk space exhaustion.

### Server Monitoring
- We recommend installing **New Relic** or **Datadog** on the production servers to monitor APM (Application Performance Monitoring).
- Monitor CPU, Memory, and Disk I/O.
- Set up alerts if the 500 Error rate exceeds 1% of total traffic.

### Database Monitoring
- Enable the MySQL Slow Query Log.
- Review queries taking longer than 1 second and optimize indexes accordingly.

---

## 📦 5. Release Management

We follow a strict release cadence:
- **Weekly Minor Updates (Patch):** Bug fixes and UI tweaks. Merged from `bugfix/*` -> `develop` -> `main`.
- **Monthly Major Updates (Minor/Major):** New modules and large features.
- All releases are tagged using SemVer (e.g., `v1.2.4`) on GitHub.

---

## 🔒 6. Production Security Checklist

Before finalizing any deployment, verify the following:

- [ ] `APP_ENV` is set to `production` in the `.env` file.
- [ ] `APP_DEBUG` is strictly set to `false`. (Debug mode exposes sensitive stack traces).
- [ ] Directory permissions are restricted (`644` for files, `755` for directories).
- [ ] The `.env` file and `storage/` directory are NOT accessible via the web browser.
- [ ] SSL/TLS is installed and HTTP traffic redirects to HTTPS.
- [ ] Database credentials in production are completely different from staging/local.
