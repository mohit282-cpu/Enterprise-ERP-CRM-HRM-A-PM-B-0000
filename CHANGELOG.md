# Changelog

All notable changes to the **Sovryx OS** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2023-10-15

### Added
- **Core Architecture:** Implemented robust MVC framework on PHP 8.3.
- **Authentication:** Added secure session management, RBAC, and Argon2 password hashing.
- **Dashboard:** Executive dashboard with dynamic ApexCharts for revenue and project tracking.
- **CRM Module:** Lead management, client database, and Kanban boards.
- **Billing Engine:** Quotation generation, dynamic PDF Invoices via Dompdf.
- **Accounting Module:** Revenue, Expenses, and basic Profit & Loss reporting.
- **Project Management:** Milestones, task assignments, and time tracking.
- **Client Portal:** Secure login for clients to view invoices and project statuses.
- **AI Integrations:** Added OpenAI connectivity for the Proposal Generator and Email Assistant.
- **Notifications:** Integrated PHPMailer for system emails and WhatsApp Business API.
- **REST API (v1):** Core endpoints for remote integrations.
- **Documentation:** Complete Enterprise-grade documentation suite.

### Security
- Implemented CSRF middleware on all POST/PUT/DELETE routes.
- Enforced strict PDO parameterization to prevent SQL injection.
- Added XSS sanitization helpers for all view outputs.
- Established comprehensive Audit Logging for state-changing actions.

---

*(Future updates will be appended here as per the [Roadmap](ROADMAP.md))*
