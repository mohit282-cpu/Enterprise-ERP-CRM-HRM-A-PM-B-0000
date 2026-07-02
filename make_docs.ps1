$basePath = "z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"

# Directories
$docsPath = Join-Path $basePath "docs"
if (-not (Test-Path $docsPath)) { New-Item -ItemType Directory -Force -Path $docsPath | Out-Null }

# 1. README.md
$readmePath = Join-Path $basePath "README.md"
$readmeContent = @'
# Sovryx OS - Enterprise Management Suite

Sovryx OS is a lightning-fast, highly modular, custom-built ERP (Enterprise Resource Planning) platform written in pure PHP 8.3. It unifies CRM, HRM, Accounting, Project Management, Inventory, and Hosting into a single, cohesive, unbreakable system.

## 🚀 Key Modules
* **Authentication:** Enterprise RBAC, Secure Sessions.
* **CRM:** Lead tracking, pipelines, automated quotes.
* **Accounting:** Immutable Double-Entry Ledger, automated P&L generation.
* **HRM:** Payroll, time-tracking, attendance integration.
* **Projects:** Kanban boards, recursive infinite sub-tasking.
* **Inventory:** Multi-warehouse mapping, strict stock-movement auditing.
* **Hosting & Domains:** Automated renewals, WHM provisioning, Unified Expiry dashboards.
* **Reporting:** Massive cross-module SQL aggregation engine.

## ⚡ Core Architecture
Sovryx OS bypasses bloated frameworks like Laravel or Symfony in favor of a lightning-fast, custom HMVC (Hierarchical Model-View-Controller) engine. 
* See the [Architecture Guide](docs/ARCHITECTURE.md) for details on the Service-Repository pattern.
* See the [Security Overview](docs/SECURITY.md) for details on our global CSRF and XSS sanitization layers.

## 📖 Documentation
Please refer to the `docs/` folder for comprehensive documentation:
* [Installation Guide](docs/INSTALLATION.md)
* [Developer Guide](docs/DEVELOPER_GUIDE.md)
* [API Documentation](docs/API_DOCUMENTATION.md)
* [Deployment Strategy](docs/DEPLOYMENT.md)

## 🤝 Contributing
Please review our [Contributing Guidelines](CONTRIBUTING.md) before submitting pull requests.

## 📄 License
This software is strictly licensed under a Proprietary Commercial License. See [LICENSE.md](LICENSE.md) for details.
'@
Set-Content -Path $readmePath -Value $readmeContent -Encoding UTF8

# 2. LICENSE.md
$licensePath = Join-Path $basePath "LICENSE.md"
$licenseContent = @'
# PROPRIETARY COMMERCIAL LICENSE

Copyright (c) 2026 Sovryx OS. All rights reserved.

This software and associated documentation files (the "Software") are proprietary and confidential.

1. **No Reproduction:** You may not copy, modify, distribute, or create derivative works of the Software without explicit, prior written permission from the copyright holder.
2. **No Distribution:** You may not sell, rent, lease, sublicense, or otherwise distribute the Software to any third party.
3. **Internal Use Only:** The Software is licensed strictly for internal deployment and operational use as per the agreed commercial contract.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED.
'@
Set-Content -Path $licensePath -Value $licenseContent -Encoding UTF8

# 3. CHANGELOG.md
$changelogPath = Join-Path $basePath "CHANGELOG.md"
$changelogContent = @'
# Changelog
All notable changes to this project will be documented in this file.

## [v1.0.0-alpha] - 2026-07-02
### Added
- **Core:** Custom HMVC architecture, global CSRF/XSS Middleware, Unified Bootstrap 5 Master Layout.
- **Testing:** PHPUnit integration with in-memory SQLite database configurations.
- **Module - Auth:** RBAC, secure session hashing.
- **Module - Accounting:** Immutable Double-Entry Ledger.
- **Module - Inventory:** Multi-warehouse `stock_movements` ledger.
- **Module - Hosting & Domains:** CRM-linked account provisioning and global Expiry dashboards.
- **Module - Reports:** Cross-module analytics engine and REST API endpoints.
- **Documentation:** Full `docs/` directory generated.
'@
Set-Content -Path $changelogPath -Value $changelogContent -Encoding UTF8

# 4. CONTRIBUTING.md
$contributingPath = Join-Path $basePath "CONTRIBUTING.md"
$contributingContent = @'
# Contributing Guidelines

Welcome to the Sovryx OS development team. Please follow these strict guidelines to maintain the integrity of the ERP.

## 1. Coding Standards
* We strictly adhere to **PSR-12** coding standards.
* Type hinting is **MANDATORY** for all function arguments and return types (PHP 8.3).
* No raw SQL queries inside Controllers. All database interaction must occur inside `Repositories`.

## 2. The Modular Pattern
If you are adding a new feature, do not place it in the core `app/` folder. Create a new module in the `modules/` directory following the HMVC structure (`Controllers/`, `Models/`, `Repositories/`, `Services/`, `Views/`, `Routes/`).

## 3. Pull Requests
* Branch off `develop`.
* Ensure all PHPUnit tests pass (`./vendor/bin/phpunit`).
* Write unit tests for any new Services, and Feature tests for any new Repositories.
'@
Set-Content -Path $contributingPath -Value $contributingContent -Encoding UTF8

# 5. docs/ARCHITECTURE.md
$architecturePath = Join-Path $basePath "docs\ARCHITECTURE.md"
$architectureContent = @'
# System Architecture

Sovryx OS utilizes a highly customized **HMVC (Hierarchical Model-View-Controller)** pattern.

## 1. The Core Application (`app/Core/`)
Contains the foundational wiring:
- `Database.php`: Singleton PDO connection.
- `Router.php`: Parses URIs and dispatches to controllers.
- `SecurityMiddleware.php`: Global CSRF and XSS protection.
- `BaseController.php`: Handles view injection into the `master.php` layout using Output Buffering.

## 2. The Modules (`modules/`)
The ERP is broken into completely isolated domains (e.g., `CRM`, `Accounting`, `HRM`). Each module contains:
* **Models:** Direct mapping to database tables.
* **Repositories:** Handles all complex SQL logic, `JOIN`s, and Database Transactions.
* **Services:** Pure business logic. The `Service` validates math or rules, then calls the `Repository`.
* **Controllers:** Only handles HTTP requests (GET/POST), calls the `Service`, and returns a View or JSON.

## 3. The Immutable Ledger Rule
Financial data (Accounting) and Physical data (Inventory) operate on an immutable ledger. 
* We NEVER update existing records to change balances. 
* We insert append-only logs (`journal_entry_lines`, `stock_movements`) and calculate totals dynamically.
'@
Set-Content -Path $architecturePath -Value $architectureContent -Encoding UTF8

# 6. docs/DEVELOPER_GUIDE.md
$devGuidePath = Join-Path $basePath "docs\DEVELOPER_GUIDE.md"
$devGuideContent = @'
# Developer Guide: Building a New Module

To build a new module (e.g., `Marketing`), follow this exact sequence:

1. **Database Schema:** Create a migration file in `database/migrations/`.
2. **Directory Structure:** Create `modules/Marketing/` with folders for `Models`, `Repositories`, `Services`, `Controllers`, `Views`, and `Routes`.
3. **Model:** Create basic classes extending `App\Core\BaseModel`.
4. **Repository:** Write methods for any `INSERT`, `UPDATE`, or complex `SELECT` queries.
5. **Service:** Write the business logic. Pass the Repository into the Service via dependency injection.
6. **Controller:** Pass the Service into the Controller. Use `$this->view('campaigns/index', [], 'Marketing')` to render the view inside the global Master Layout.
7. **Routes:** Define the endpoints in `modules/Marketing/Routes/web.php`.
8. **UI Registration:** Add the module to the Sidebar array inside `app/Views/layouts/master.php`.
'@
Set-Content -Path $devGuidePath -Value $devGuideContent -Encoding UTF8

# 7. docs/API_DOCUMENTATION.md
$apiDocPath = Join-Path $basePath "docs\API_DOCUMENTATION.md"
$apiDocContent = @'
# API Documentation

Sovryx OS exposes a highly secure REST API for headless operations.

## 1. Base URL
All API requests must prefix the URI with `/api/` (e.g., `https://erp.sovryx.com/api/reports/finance`).

## 2. Authentication
Every request must include an `Authorization` header containing a valid Bearer token.
`Authorization: Bearer d3b07384d113edec49eaa6238ad5ff00`

If this token is missing or invalid, the global `ApiMiddleware` will instantly terminate the request with a `401 Unauthorized`.

## 3. Standardized Responses
All endpoints extending `App\Core\ApiController` return a strict JSON format:
```json
{
  "success": true,
  "message": "Operation completed.",
  "data": { ... }
}
```

## 4. Swagger UI
You can view the interactive, auto-generated OpenAPI 3.0 specification by navigating to `/api/docs` in your browser.
'@
Set-Content -Path $apiDocPath -Value $apiDocContent -Encoding UTF8

# 8. docs/INSTALLATION.md
$installPath = Join-Path $basePath "docs\INSTALLATION.md"
$installContent = @'
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
'@
Set-Content -Path $installPath -Value $installContent -Encoding UTF8

# 9. docs/DEPLOYMENT.md
$deploymentPath = Join-Path $basePath "docs\DEPLOYMENT.md"
$deploymentContent = @'
# Production Deployment

When deploying Sovryx OS to a production Linux server (Ubuntu/Nginx):

## 1. Document Root
Configure Nginx to point the root strictly to the `/public` directory. **NEVER** expose the `/app`, `/modules`, or `/database` directories to the public web.

## 2. Environment Variables
Ensure the production `.env` file is heavily guarded (chmod 600) and contains the live database credentials.

## 3. SSL/TLS
The system architecture assumes HTTPS. The global `SecurityMiddleware` enforces `Strict-Transport-Security`. If you deploy without an SSL certificate, modern browsers will reject connections to the ERP.
'@
Set-Content -Path $deploymentPath -Value $deploymentContent -Encoding UTF8

# 10. docs/SECURITY.md
$securityPath = Join-Path $basePath "docs\SECURITY.md"
$securityContent = @'
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
'@
Set-Content -Path $securityPath -Value $securityContent -Encoding UTF8

# 11. docs/ROADMAP.md
$roadmapPath = Join-Path $basePath "docs\ROADMAP.md"
$roadmapContent = @'
# Strategic Roadmap

## Phase 1: Core Architecture (COMPLETED)
- Built HMVC Database schemas for 10+ modules.
- Established API, Testing, Security, and UI frameworks.

## Phase 2: User Interface & Polish (UPCOMING)
- Systematically inject all raw module views into the `master.php` layout.
- Implement DomPDF for invoice/report generation.
- Implement PhpSpreadsheet for Excel exports.
- Integrate WHM/cPanel REST APIs into the Hosting module.

## Phase 3: Real-Time & Mobile
- Integrate WebSockets (Ratchet/Pusher) for real-time CRM chat and Dashboard notifications.
- Build headless React Native mobile applications consuming the `/api/` endpoints.
'@
Set-Content -Path $roadmapPath -Value $roadmapContent -Encoding UTF8

Write-Host "Project Documentation generated successfully."
