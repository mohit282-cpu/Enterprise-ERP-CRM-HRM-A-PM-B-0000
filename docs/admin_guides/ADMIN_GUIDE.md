# Administrator Guide

Welcome to the **Sovryx OS** Administrator Guide. This document explains how system administrators can configure global settings, manage user roles, and monitor system health.

---

## ⚙️ 1. System Settings

The Global Settings panel is accessible only to users with the `Super Admin` role.

### General Configuration
- **Company Name & Logo:** Set the official company name and upload the branding logo used on the login screen and generated PDF invoices.
- **Localization:** Set the default timezone (e.g., `Asia/Kathmandu`), date format (`YYYY-MM-DD`), and base currency (e.g., `NPR` or `USD`).
- **Fiscal Year:** Define the start and end month of the financial year for accurate reporting.

### API Integrations
Configure third-party services required for Sovryx OS to function at full capacity:
- **SMTP Settings:** Configure your Mail server (e.g., Mailgun, Sendgrid) for system emails.
- **WhatsApp API:** Input your WhatsApp Business API Token and Phone Number ID for omnichannel alerts.
- **OpenAI Integration:** Enter your OpenAI API Key to enable the AI Proposal Generator and AI Email Assistant.

---

## 👥 2. User & Role Management (RBAC)

Sovryx OS uses a strict Role-Based Access Control system.

### Creating Roles
1. Navigate to **Settings > Roles & Permissions**.
2. Click **Create New Role**.
3. Name the role (e.g., `Junior Accountant`).
4. Select the granular permissions from the checklist:
   - `[x] view_invoices`
   - `[x] create_invoices`
   - `[ ] delete_invoices` (leave unchecked to prevent deletion)

### Managing Users
- To add a new user, go to **User Management > Add User**.
- Fill in the required details and assign one or more Roles.
- Users can be marked as `Active` or `Suspended`. Suspended users cannot log into the system.

---

## 🛡 3. Security & Audit Logs

### Audit Trail
Administrators have access to the **Audit Logs** module. This tracks every state-changing action in the system.
- You can filter logs by **User**, **Module** (e.g., Invoices), or **Action Type** (Create, Update, Delete).
- *Example:* If an invoice is deleted, the log will show exactly who deleted it, their IP address, and the exact timestamp.

### Session Management
- Administrators can view active sessions in the **Security** panel.
- If a user's account is compromised, you can click **Revoke All Sessions** to instantly log them out across all devices.

---

## 💾 4. Backups and Maintenance

### Automated Backups
Ensure that your cron job is running (see [Installation Guide](INSTALLATION.md)).
- Backups are stored in `storage/backups/`.
- Navigate to **Settings > Backups** to download database SQL dumps or trigger a manual backup.

### Cache Clearing
If you update the `.env` file or change translation files, you must clear the system cache.
- Navigate to **Settings > Maintenance**.
- Click **Clear System Cache**. This will safely purge the configuration and view caches.

---

## 🏢 5. SaaS Management (If Enabled)

If you are running the multi-tenant SaaS version of Sovryx OS:
- **Tenant Overview:** View all registered companies using your software.
- **Subscription Plans:** Create tiers (e.g., Basic, Pro, Enterprise) and set module limits (e.g., Max 50 Invoices/month).
- **Tenant Suspension:** Manually suspend a tenant if their billing fails.
