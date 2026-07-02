# 🏗️ Sovryx OS: Enterprise Architecture & File Structure

**Project:** Sovryx OS  
**Company:** Sovryx Tech  
**Type:** Enterprise Business Operating System (ERP + CRM + HRM + Accounting + Project Management)  
**Tech Stack:** PHP 8.3+, MVC, Modular Domain-Driven Design (DDD), MySQL 8+, Bootstrap 5, AJAX.

This document outlines the professional, scalable, and modular enterprise-grade file structure designed for Sovryx OS. It adopts principles from leading enterprise systems like Laravel, ERPNext, Odoo, SAP, and Microsoft Dynamics, ensuring strict module isolation, immense scalability, and long-term maintainability.

---

## 📂 1. Enterprise Project Folder Structure

Sovryx OS utilizes a **Modular Architecture** (Domain-Driven Design). Instead of grouping all controllers together and all models together (Standard MVC), the system groups files by **Business Domain** (e.g., `HRM`, `Accounting`, `CRM`) inside the `modules/` directory.

```text
SovryxOS/
│
├── app/                              # Core Framework & Global Application Logic
│   ├── Console/                      # Custom CLI Commands (e.g., Cron Jobs, Scaffolding)
│   ├── Exceptions/                   # Global Exception Handlers (404, 500, Custom Errors)
│   ├── Helpers/                      # Global Utility Functions (Formatting, Math, Sanitization)
│   ├── Http/                         # Global HTTP Layer
│   │   ├── Controllers/              # Core Controllers (BaseController, Fallback)
│   │   ├── Middleware/               # Global Middleware (Auth, CSRF, RBAC, Rate Limiting)
│   │   └── Requests/                 # Global Form Validation Requests
│   ├── Providers/                    # Service Providers (App, Route, Event, Module Loader)
│   └── Support/                      # Core System Utilities & Framework Engine
│
├── bootstrap/                        # Application Bootstrapping
│   ├── cache/                        # Framework Generated Cache Files (Routes, Config)
│   └── app.php                       # Initial Bootstrapper & Auto-loader Setup
│
├── config/                           # System Configuration Files
│   ├── app.php                       # App Name, Timezone, Locale
│   ├── auth.php                      # Authentication Settings & Guards
│   ├── database.php                  # PDO & MySQL Connection Settings
│   ├── mail.php                      # SMTP / PHPMailer Config
│   ├── modules.php                   # Registry of Active/Inactive Modules
│   └── security.php                  # Encryption, Hashing, and CORS settings
│
├── database/                         # Global Database Scripts (System Level)
│   ├── migrations/                   # Core System Migrations (Users, Roles, Settings)
│   ├── seeders/                      # Core System Seeders (Default Admin, Config)
│   └── factories/                    # Model Factories for Testing
│
├── docs/                             # Comprehensive Project Documentation
│   ├── architecture/                 # System Design & Diagrams
│   ├── api/                          # REST API Endpoints & Postman Collections
│   ├── admin_guides/                 # Manuals for System Administrators
│   ├── developer_guides/             # Coding Standards & Contribution Rules
│   └── user_guides/                  # End-User Manuals (HR, Sales, Accounting)
│
├── modules/                          # 🚀 ENTERPRISE BUSINESS MODULES (Domain Driven)
│   │
│   ├── Accounting/                   # Example of an Expanded Module
│   │   ├── Config/                   # Module-Specific Configurations
│   │   ├── Controllers/              # Web & API Controllers (e.g., LedgerController)
│   │   ├── Models/                   # Data Models (e.g., Transaction, Account)
│   │   ├── Views/                    # HTML Templates (e.g., reports/pnl.php)
│   │   ├── Services/                 # Business Logic (e.g., DoubleEntryService)
│   │   ├── Repositories/             # Data Access Abstraction (e.g., TransactionRepository)
│   │   ├── Interfaces/               # Contracts (e.g., LedgerInterface)
│   │   ├── Policies/                 # Authorization Rules (e.g., CanVoidTransaction)
│   │   ├── Requests/                 # Form Validators (e.g., CreateTransactionRequest)
│   │   ├── Resources/                # API Data Transformers
│   │   ├── Events/                   # Domain Events (e.g., PaymentReceived)
│   │   ├── Listeners/                # Event Handlers (e.g., UpdateLedgerBalance)
│   │   ├── Jobs/                     # Background Queues (e.g., GenerateMonthlyReport)
│   │   ├── Notifications/            # Internal & Email Alerts
│   │   ├── Mail/                     # Email Templates (Mailable Classes)
│   │   ├── Database/
│   │   │   ├── Migrations/           # Accounting Tables (chart_of_accounts, ledgers)
│   │   │   └── Seeders/              # Default Account Structures
│   │   ├── Routes/
│   │   │   ├── web.php               # Accounting UI Routes
│   │   │   └── api.php               # Accounting API Routes
│   │   └── assets/                   # Module-specific JS/CSS
│   │
│   ├── Authentication/               # Login, SSO, JWT, Session Management
│   ├── Dashboard/                    # Executive Summaries, Widgets, Analytics
│   ├── CRM/                          # Leads, Clients, Pipelines, Deals
│   ├── ERP/                          # Core Resource Planning & Inter-module linking
│   ├── Projects/                     # Project Tracking, Milestones, Kanban
│   ├── Tasks/                        # Individual Task Assignment, Time Tracking
│   ├── Billing/                      # Invoicing, Quotations, Payments
│   ├── HRM/                          # Employees, Departments, Attendance, Leaves
│   ├── Payroll/                      # Salary Calculation, Deductions, Payslips
│   ├── Inventory/                    # Stock, Warehouses, Product Variants
│   ├── Sales/                        # Orders, POS, Sales Funnel
│   ├── Marketing/                    # Campaigns, Email Broadcasts, Lead Generation
│   ├── Support/                      # Help Desk, Ticketing System, SLAs
│   ├── Hosting/                      # Server Management, cPanel Integration
│   ├── Domains/                      # Domain Registration & Expiry Tracking
│   ├── TrainingInstitute/            # Courses, Students, Certifications
│   ├── SaaS/                         # Multi-Tenancy, Subscriptions, API Limits
│   ├── Documents/                    # Secure File Storage, Versioning, Signing
│   ├── KnowledgeBase/                # Internal Wikis, Client FAQs
│   ├── Reports/                      # Custom Report Builder, PDF Exports
│   ├── Analytics/                    # Business Intelligence, ApexCharts Integration
│   ├── Settings/                     # Global Preferences, Currencies, Taxes
│   ├── Notifications/                # System Alerts, Email, WhatsApp, SMS Logic
│   ├── AI_Assistant/                 # OpenAI Prompts, Text Generation, Chatbots
│   ├── VendorManagement/             # Suppliers, Purchase Orders
│   ├── Procurement/                  # Requisitions, Approvals, Supply Chain
│   ├── Assets/                       # Fixed Assets, Depreciation, Handover Logs
│   ├── Calendar/                     # Scheduling, Meetings, Syncing
│   ├── WorkflowAutomation/           # Triggers, Actions, Zapier-like Webhooks
│   ├── AuditLogs/                    # Compliance, User Action Tracking
│   ├── ActivityLogs/                 # Recent System Activities for Dashboard
│   ├── ClientPortal/                 # Customer-facing Views and Logic
│   └── EmployeePortal/               # Staff-facing Views (Self Service HR)
│
├── public/                           # Web Root (Document Root)
│   ├── index.php                     # The Front Controller (Entry Point)
│   ├── .htaccess                     # Apache Routing Rules
│   ├── assets/                       # Compiled Global Assets
│   │   ├── css/                      # Minified CSS, Bootstrap overrides
│   │   ├── js/                       # Minified JS, AJAX logic
│   │   ├── images/                   # Global UI Images, Logos
│   │   └── fonts/                    # FontAwesome, Webfonts
│   └── uploads/                      # Publicly Accessible User Uploads
│       ├── avatars/                  # User Profile Pictures
│       ├── logos/                    # Company/Tenant Logos
│       └── temp/                     # Temporary public files
│
├── resources/                        # Uncompiled Assets & Global Views
│   ├── views/                        # Global Layouts & Shared UI
│   │   ├── layouts/                  # master.php, auth.php, portal.php
│   │   ├── components/               # Reusable UI (buttons, modals, tables)
│   │   ├── emails/                   # Master HTML Email Templates
│   │   └── errors/                   # 404.php, 500.php, 403.php
│   ├── js/                           # Source JavaScript (ES6 Modules)
│   ├── sass/                         # Source SCSS (Variables, Mixins)
│   └── lang/                         # Localization (i18n)
│       ├── en/                       # English strings
│       └── es/                       # Spanish strings
│
├── routes/                           # Global Routing Definitions
│   ├── web.php                       # Core Web Routes (Requires Session)
│   ├── api.php                       # Core API Routes (Requires Token)
│   ├── console.php                   # CLI Routes & Commands
│   └── channels.php                  # WebSockets / Real-time Broadcasting
│
├── storage/                          # Application Generated & Protected Files
│   ├── app/                          # Internal Storage (Not public)
│   │   ├── invoices/                 # Generated PDF Invoices
│   │   ├── documents/                # Secure HR & Client Documents
│   │   ├── contracts/                # Signed PDF Contracts
│   │   ├── receipts/                 # Uploaded Expense Receipts
│   │   ├── exports/                  # Generated CSV/Excel Files
│   │   └── imports/                  # Pending CSV/Excel Uploads
│   ├── framework/                    # Framework Engine Files
│   │   ├── cache/                    # Data & Route Cache
│   │   ├── sessions/                 # File-based Sessions
│   │   └── views/                    # Compiled View Templates
│   ├── logs/                         # Application Logs
│   │   ├── system.log                # Core Errors & Exceptions
│   │   ├── auth.log                  # Login Attempts & Failures
│   │   └── api.log                   # Incoming API Request tracking
│   ├── backups/                      # Automated Database & File Backups
│   └── temp/                         # Temporary Files (PDF processing, zips)
│
├── tests/                            # Automated Testing Suite
│   ├── Unit/                         # Isolated Unit Tests (e.g., Tax calculation)
│   ├── Feature/                      # Integration Tests (e.g., API flows)
│   ├── Browser/                      # UI Testing (Selenium/Dusk)
│   ├── API/                          # REST API Tests
│   └── Database/                     # Database consistency tests
│
├── scripts/                          # DevOps, DB, and Utility Scripts
│   ├── install.sh                    # Initial setup script
│   ├── backup.sh                     # Manual backup trigger
│   ├── deploy.sh                     # CI/CD deployment script
│   └── cleanup.sh                    # Purge temp files and old logs
│
├── docker/                           # Dockerized Development & Production Envs
│   ├── nginx/                        # Nginx Configs
│   ├── mysql/                        # Database Configs
│   ├── php/                          # PHP-FPM / php.ini Configs
│   └── docker-compose.yml            # Container orchestration
│
├── .github/                          # GitHub Actions & CI/CD
│   ├── workflows/
│   │   ├── ci.yml                    # Automated Testing on Push
│   │   └── deploy.yml                # Automated Deployment to Prod
│   └── ISSUE_TEMPLATE/               # Bug & Feature templates for Repo
│
├── plugins/                          # 3rd Party Extensions / White-label Modules
│   └── payment-gateways/             # e.g., Stripe, PayPal plugins
│
├── themes/                           # White-labeling & UI Skins
│   ├── default/
│   └── modern-dark/
│
├── installer/                        # Web-based Installation Wizard (for end-users)
│   ├── index.php
│   └── check_requirements.php
│
├── composer.json                     # PHP Dependencies (Packages, Autoloader)
├── package.json                      # NPM Dependencies (Webpack, SCSS compilers)
├── .env.example                      # Template for Environment Variables
├── .gitignore                        # Git exclusion rules
├── phpunit.xml                       # PHPUnit Test Configuration
└── README.md                         # Main Project Overview
```

---

## 🏛 2. Architectural Paradigms Explained

### Why this Architecture? (Modular DDD)
Traditional MVC (like default Laravel or CodeIgniter) groups all controllers in one folder and all models in another. In a massive ERP with 30+ modules, this creates a "fat folder" problem (e.g., hundreds of controllers in `app/Controllers`). 

**Modular Architecture (Domain-Driven Design)** solves this by treating each business capability (Accounting, HRM, CRM) as a self-contained "mini-application" inside the `modules/` folder. This is how enterprise software like **Odoo** and **ERPNext** is structured.

### Advantages
1. **Module Isolation:** You can disable, remove, or update the `HRM` module without touching or breaking the `Accounting` module.
2. **Team Collaboration:** Different developers can work on different modules simultaneously without causing merge conflicts in central route or controller files.
3. **Plug-and-Play:** Modules act like plugins. This is essential for the `SaaS` roadmap, allowing you to charge clients based on which modules they activate.

### Scalability
- **Codebase Scalability:** Adding a new module (e.g., Fleet Management) just means creating a new folder in `/modules/`. The core remains untouched.
- **Infrastructure Scalability:** The strict separation of the `storage/` directory allows the web root to be entirely stateless. This means Sovryx OS can be deployed across multiple load-balanced web servers while sharing a central database and AWS S3 storage.

### Security
- **Public Sandbox:** The `/public` folder is the ONLY directory accessible from the internet. All core logic, configurations, and `.env` files sit safely behind the web root, making directory traversal attacks nearly impossible.
- **RBAC & Policies:** Every module contains a `Policies/` directory. This ensures that authorization logic (e.g., "Can this user delete this invoice?") is strictly encapsulated and decoupled from the controllers.

### Performance
- **Lazy Loading Modules:** The `config/modules.php` registry ensures that only active modules are loaded into memory during the Request Lifecycle.
- **Caching:** Extensive caching mechanisms inside `storage/framework/cache/` prevent recompiling views and routes on every request.

### Maintainability & Coding Standards
- Following **PSR-4** autoloading and **PSR-12** coding standards ensures that any PHP developer can immediately understand the file structure.
- The use of **Interfaces** and **Repositories** decouples the application logic from the database, meaning you could swap MySQL for PostgreSQL in the future with minimal refactoring.

---

## 🔄 3. MVC Flow & Dependency Flow

### Request Lifecycle
1. **Incoming Request:** User accesses `https://app.com/accounting/invoices`.
2. **Front Controller:** `public/index.php` captures the request.
3. **Bootstrapper:** `bootstrap/app.php` initializes the core framework and auto-loader.
4. **Middleware:** Request passes through Global Middleware (Security, Auth).
5. **Router:** The system checks the active modules and finds a match in `modules/Accounting/Routes/web.php`.
6. **Controller:** The request hits `InvoiceController`.
7. **Form Request Validation:** Input is validated via `CreateInvoiceRequest`.
8. **Service/Repository Layer:** The Controller calls `InvoiceService`, which handles business logic and fetches data via `InvoiceRepository` (Model).
9. **View Generation:** The Controller passes the data to `modules/Accounting/Views/invoices/index.php`.
10. **Response:** HTML (or JSON) is returned to the user.

### Dependency Flow (Strict Rules)
- **Controllers** should ONLY handle HTTP logic (request parsing, response formatting). They should NOT contain business logic or complex SQL.
- **Services** contain the actual business rules (e.g., calculating taxes, calling OpenAI APIs).
- **Repositories** contain the database queries. Services call Repositories; they do not call Models directly.
- **Models** are purely representations of database tables and relations.

---

## 📁 4. Folder Responsibility Breakdown

### `app/`
Contains the scaffolding that runs the entire OS. This includes global Middlewares (checking if a user is logged in), global exception formatting, and custom CLI console commands.

### `modules/`
The heart of Sovryx OS. Every folder inside here represents a completely independent business vertical. They contain their own routes, controllers, views, and database migrations.

### `resources/`
Contains assets that need processing (like SCSS files that need to be compiled into CSS) and global layout files (like the sidebar and header) that are shared across all modules.

### `storage/`
Crucial for enterprise security. User uploads like signed contracts and PDF invoices go into `storage/app/`. They are NOT placed in `public/`. To view an invoice, a user must hit a protected route, which streams the file from `storage/` after verifying their RBAC permissions.

### `database/`
Houses the system's architecture history. `migrations` ensure that setting up a new server automatically builds the MySQL schema. `seeders` inject dummy data or essential configurations (like default currencies and Admin roles).

### `tests/`
Houses automated PHPUnit tests. In enterprise systems, no code is deployed without passing tests in the `Unit` (testing a specific calculation) and `Feature` (testing a full API request) directories.

---

## 🏆 5. Best Practices Enforced by this Structure

1. **Fat Models, Skinny Controllers? No. Skinny Everything:** By utilizing Services and Repositories, neither the Controller nor the Model becomes a monolithic 3,000-line file.
2. **Form Requests:** Input validation is moved out of the Controller and into dedicated `Requests/` classes, keeping controllers exceptionally clean.
3. **API Resources:** The `Resources/` folder in each module ensures that API JSON responses are standardized and don't accidentally leak sensitive database columns (like password hashes).
4. **Event-Driven Architecture:** When a new Client is created in CRM, it fires an `Event`. The Notification module listens to this event and sends an email. The Modules do not tightly couple or call each other directly; they communicate via Events.
