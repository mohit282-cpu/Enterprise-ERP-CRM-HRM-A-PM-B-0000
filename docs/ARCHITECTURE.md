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
