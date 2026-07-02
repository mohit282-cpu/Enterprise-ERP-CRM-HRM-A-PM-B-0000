# Security Overview

Sovryx OS is built with paranoid security defaults.

## 1. Global Interceptors
The `SecurityMiddleware` automatically runs on every request:
- **CSRF:** All `POST/PUT/DELETE` requests require a valid `csrf_token`.
- **Headers:** Injects `X-Frame-Options`, `X-XSS-Protection`, and `Content-Security-Policy`.

## 2. Data Sanitization
The core `Sanitizer::escape()` uses `htmlspecialchars` with `ENT_QUOTES | ENT_HTML5` to neutralize any XSS payloads before they reach the database or views.

## 3. Audit Logs
Any data modification triggers the `AuditLoggerService`, logging the user, IP address, and exact JSON diff (`old_values` vs `new_values`).

## Reporting Vulnerabilities
If you discover a security vulnerability, please email `security@sovryx.com` immediately. Do not open public GitHub issues.
