# Developer Guide

Welcome to the **Sovryx OS** Developer Guide. This document establishes the engineering culture, coding standards, and collaborative workflows required to contribute to this enterprise product.

---

## 📐 Coding Standards

We adhere strictly to the PHP-FIG standards to ensure uniformity and readability across the massive codebase.

1. **PSR-12 Compliance:** All PHP code MUST follow the PSR-12 coding standard.
2. **Strict Typing:** Every PHP file MUST declare strict types at the very top:
   ```php
   <?php
   declare(strict_types=1);
   ```
3. **Type Hinting:** All method arguments and return types MUST be explicitly typed.
   ```php
   public function calculateTax(float $amount, int $taxRate): float {
       return $amount * ($taxRate / 100);
   }
   ```
4. **Documentation Blocks (PHPDoc):** All classes, properties, and methods MUST have descriptive DocBlocks explaining parameters, return types, and potential exceptions.

---

## 📁 Naming Conventions

### 1. Folders and Files
- **Classes:** `PascalCase` (e.g., `InvoiceController.php`, `AuthMiddleware.php`).
- **Views:** `snake_case` (e.g., `dashboard_index.php`, `create_invoice.php`).
- **Assets:** `kebab-case` (e.g., `main-stylesheet.css`, `app-scripts.js`).

### 2. Classes and Methods
- **Classes/Interfaces/Traits:** `PascalCase` (e.g., `class PaymentGateway`).
- **Methods:** `camelCase` (e.g., `public function generatePdf()`).
- **Constants:** `UPPER_SNAKE_CASE` (e.g., `const MAX_UPLOAD_SIZE = 2048;`).
- **Variables:** `camelCase` (e.g., `$invoiceTotal`).

### 3. Database Naming (See [DATABASE.md](DATABASE.md))
- **Tables:** Plural `snake_case` (e.g., `users`, `invoice_items`).
- **Columns:** Singular `snake_case` (e.g., `email`, `created_at`).

---

## 🌿 Git Workflow & Branching Strategy

We utilize a robust Git Flow to prevent production breakages.

### Branch Structure
- `main`: **Production Ready.** Contains only thoroughly tested, stable code. Deploys directly to production servers.
- `develop`: **Integration Branch.** The active development branch where features are merged before release.
- `feature/*`: For new features (e.g., `feature/whatsapp-integration`). Branched from `develop`.
- `bugfix/*`: For non-critical bug fixes (e.g., `bugfix/invoice-calc-error`). Branched from `develop`.
- `hotfix/*`: For critical production bugs (e.g., `hotfix/auth-bypass`). Branched from `main` and merged into BOTH `main` and `develop`.

### Commit Convention
We follow the **Conventional Commits** specification.
Format: `<type>(<scope>): <subject>`

Examples:
- `feat(billing): implement recurring invoice cron job`
- `fix(auth): resolve session hijacking vulnerability`
- `docs(api): update swagger definitions for project endpoints`
- `style(ui): align data table headers in dark mode`

---

## 🔍 Code Review Process

All code merged into `develop` or `main` MUST pass a rigorous review process.

1. **Pull Request (PR) Creation:**
   - Link the PR to the relevant issue tracker.
   - Include a detailed description of what was changed and why.
   - Attach UI screenshots if frontend changes were made.
2. **Automated Checks:**
   - GitHub Actions will automatically run PHPUnit tests and PHP CodeSniffer. The PR cannot be merged if these fail.
3. **Peer Review:**
   - Require at least ONE approval from Developer 1 or Developer 2.
   - Reviewers must check for: Architecture adherence, security flaws (SQLi, XSS), performance impacts, and naming conventions.

---

## 🚀 Deployment Strategy

### CI/CD Pipeline
- **Push to `develop`:** Triggers automated testing and deploys to the Staging Environment.
- **Push to `main`:** Triggers tests, minifies assets, runs database migrations automatically, and deploys to Production.

### Rollbacks
If a production deployment fails, we utilize automated symlink switching (via tools like Deployer or GitHub Actions) to instantly revert the webroot to the previous stable release directory.

---

## 🏷 Versioning

Sovryx OS uses **Semantic Versioning (SemVer)**: `MAJOR.MINOR.PATCH`.

- **MAJOR:** Incompatible API changes or massive architectural overhauls.
- **MINOR:** Adding new functionality in a backwards-compatible manner (e.g., adding the HRM module).
- **PATCH:** Backwards-compatible bug fixes (e.g., fixing a CSS alignment).
