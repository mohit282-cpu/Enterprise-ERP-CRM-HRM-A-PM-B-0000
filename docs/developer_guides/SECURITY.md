# Security Policy

Security is the highest priority for **Sovryx OS**. As an Enterprise Business Operating System handling sensitive financial, CRM, and HR data, we employ a defense-in-depth approach to protect the integrity, confidentiality, and availability of data.

---

## 🛡 1. Authentication & Authorization

### Authentication
- **Web Sessions:** Handled via secure, HTTP-only, and SameSite PHP sessions to mitigate XSS-based session hijacking.
- **API Access:** Secured using Bearer Tokens (JSON Web Tokens or encrypted stateless tokens).
- **Password Policy:** All passwords must be at least 12 characters long, containing a mix of uppercase, lowercase, numbers, and symbols. 
- **Encryption:** Passwords are never stored in plaintext. They are hashed using the **Argon2** algorithm (or Bcrypt as a fallback).

### Authorization & RBAC
Sovryx OS utilizes a granular **Role-Based Access Control (RBAC)** system.
- Users are assigned **Roles** (e.g., Admin, HR Manager, Employee).
- Roles are assigned specific **Permissions** (e.g., `view_invoices`, `delete_projects`).
- Middleware sits before every controller method to verify if the active user session holds the necessary permission to execute the action.

---

## 🕸 2. Threat Prevention

### Cross-Site Scripting (XSS)
- All user-supplied data rendered in the UI is strictly escaped using `htmlspecialchars()` with `ENT_QUOTES`.
- Our UI components avoid rendering raw HTML unless processed through a strict HTML Purifier library (used only for rich text areas like the Knowledge Base).

### Cross-Site Request Forgery (CSRF)
- A unique CSRF token is generated for every user session.
- Every state-changing request (POST, PUT, DELETE, PATCH) submitted via web forms or AJAX must include the `X-CSRF-TOKEN` header or a hidden input field. Requests without a valid token are immediately rejected with a `419 Page Expired` error.

### SQL Injection (SQLi)
- Raw SQL queries are **strictly forbidden**.
- All database interactions utilize PHP Data Objects (PDO) with prepared statements and parameter binding, making SQL injection virtually impossible.

---

## 🔒 3. Data Protection

### Encryption in Transit
- Sovryx OS **must** be deployed over HTTPS. TLS 1.2 or higher is required.
- API endpoints reject unencrypted HTTP requests in production.

### Encryption at Rest
- Highly sensitive application configuration (like database passwords, API keys) are stored in the `.env` file, which is kept outside the public web root and excluded from version control.

### Session Security
- `session.cookie_httponly = 1`
- `session.cookie_secure = 1` (in production)
- `session.use_strict_mode = 1`
- Sessions are automatically invalidated and regenerated upon privilege escalation (e.g., logging in).

---

## 📜 4. Auditing & Monitoring

### Comprehensive Audit Logs
Every critical action within Sovryx OS is recorded in the `audit_logs` table.
- **Logged Events:** Login attempts, Invoice creation/deletion, Payment processing, Permission changes, User creation.
- **Captured Data:** Action type, User ID, IP Address, User-Agent, Timestamp, and previous/new data states.

### Backups
- Database dumps and uploaded files are backed up automatically via a nightly cron job.
- Backups are encrypted before being pushed to off-site cloud storage.

---

## 🚨 Reporting a Vulnerability

If you discover a security vulnerability within Sovryx OS, please do **NOT** open a public issue on GitHub.

Instead, please send an email to **security@sovryxtech.com**. 

**Please include:**
1. A description of the vulnerability.
2. Steps to reproduce the issue.
3. Potential impact.

Our team will acknowledge receipt within 24 hours and will work diligently to release a patch.
