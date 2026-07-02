$basePath = "z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"
$migrationsPath = Join-Path $basePath "database\migrations"

if (-not (Test-Path $migrationsPath)) {
    New-Item -ItemType Directory -Force -Path $migrationsPath | Out-Null
}

$masterDataMigration = Join-Path $migrationsPath "2026_01_02_000000_create_master_data_tables.php"
$masterDataContent = @'
<?php

class CreateMasterDataTables {
    public function up($db) {
        $sql = "
        CREATE TABLE customers (
            id INT AUTO_INCREMENT PRIMARY KEY,
            uuid CHAR(36) NOT NULL UNIQUE,
            name VARCHAR(255) NOT NULL,
            email VARCHAR(255),
            phone VARCHAR(50),
            address TEXT,
            status ENUM('active', 'inactive') DEFAULT 'active',
            account_manager_id INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (account_manager_id) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE vendors (
            id INT AUTO_INCREMENT PRIMARY KEY,
            uuid CHAR(36) NOT NULL UNIQUE,
            name VARCHAR(255) NOT NULL,
            email VARCHAR(255),
            phone VARCHAR(50),
            status ENUM('active', 'inactive') DEFAULT 'active',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        );

        CREATE TABLE warehouses (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            location VARCHAR(255),
            branch_id INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE SET NULL
        );

        CREATE TABLE products (
            id INT AUTO_INCREMENT PRIMARY KEY,
            sku VARCHAR(100) NOT NULL UNIQUE,
            name VARCHAR(255) NOT NULL,
            description TEXT,
            price DECIMAL(15,4) NOT NULL DEFAULT 0.0000,
            cost DECIMAL(15,4) NOT NULL DEFAULT 0.0000,
            type ENUM('goods', 'service') DEFAULT 'goods',
            stock_quantity INT DEFAULT 0,
            warehouse_id INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON DELETE SET NULL
        );
        ";
        $db->exec($sql);
    }

    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS products, warehouses, vendors, customers;");
    }
}
'@
Set-Content -Path $masterDataMigration -Value $masterDataContent -Encoding UTF8

$operationalMigration = Join-Path $migrationsPath "2026_01_03_000000_create_operational_tables.php"
$operationalContent = @'
<?php

class CreateOperationalTables {
    public function up($db) {
        $sql = "
        CREATE TABLE leads (
            id INT AUTO_INCREMENT PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            customer_id INT,
            assigned_to INT,
            status ENUM('new', 'contacted', 'qualified', 'lost', 'won') DEFAULT 'new',
            value DECIMAL(15,4) DEFAULT 0.0000,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
            FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE projects (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            customer_id INT,
            manager_id INT,
            status ENUM('planned', 'in_progress', 'on_hold', 'completed', 'cancelled') DEFAULT 'planned',
            start_date DATE,
            end_date DATE,
            budget DECIMAL(15,4) DEFAULT 0.0000,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
            FOREIGN KEY (manager_id) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE tasks (
            id INT AUTO_INCREMENT PRIMARY KEY,
            project_id INT NOT NULL,
            title VARCHAR(255) NOT NULL,
            description TEXT,
            assigned_to INT,
            status ENUM('todo', 'in_progress', 'review', 'done') DEFAULT 'todo',
            due_date DATE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
            FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL
        );
        ";
        $db->exec($sql);
    }

    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS tasks, projects, leads;");
    }
}
'@
Set-Content -Path $operationalMigration -Value $operationalContent -Encoding UTF8

$financeMigration = Join-Path $migrationsPath "2026_01_04_000000_create_finance_tables.php"
$financeContent = @'
<?php

class CreateFinanceTables {
    public function up($db) {
        $sql = "
        CREATE TABLE chart_of_accounts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            code VARCHAR(50) NOT NULL UNIQUE,
            name VARCHAR(255) NOT NULL,
            type ENUM('asset', 'liability', 'equity', 'revenue', 'expense') NOT NULL,
            is_active BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE invoices (
            id INT AUTO_INCREMENT PRIMARY KEY,
            invoice_number VARCHAR(100) NOT NULL UNIQUE,
            customer_id INT NOT NULL,
            subtotal DECIMAL(15,4) DEFAULT 0.0000,
            tax_total DECIMAL(15,4) DEFAULT 0.0000,
            grand_total DECIMAL(15,4) DEFAULT 0.0000,
            status ENUM('draft', 'sent', 'paid', 'void') DEFAULT 'draft',
            issue_date DATE,
            due_date DATE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT
        );

        CREATE TABLE invoice_items (
            id INT AUTO_INCREMENT PRIMARY KEY,
            invoice_id INT NOT NULL,
            product_id INT,
            description TEXT,
            quantity INT NOT NULL DEFAULT 1,
            unit_price DECIMAL(15,4) NOT NULL DEFAULT 0.0000,
            total DECIMAL(15,4) NOT NULL DEFAULT 0.0000,
            FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
            FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL
        );

        CREATE TABLE payments (
            id INT AUTO_INCREMENT PRIMARY KEY,
            invoice_id INT NOT NULL,
            customer_id INT NOT NULL,
            amount DECIMAL(15,4) NOT NULL,
            payment_method ENUM('cash', 'bank_transfer', 'credit_card', 'paypal') NOT NULL,
            payment_date DATE NOT NULL,
            reference_number VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
            FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT
        );

        CREATE TABLE journal_entries (
            id INT AUTO_INCREMENT PRIMARY KEY,
            account_id INT NOT NULL,
            reference_type VARCHAR(100), -- e.g., 'invoice', 'payment'
            reference_id INT,
            debit DECIMAL(15,4) DEFAULT 0.0000,
            credit DECIMAL(15,4) DEFAULT 0.0000,
            entry_date DATE NOT NULL,
            description TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (account_id) REFERENCES chart_of_accounts(id) ON DELETE RESTRICT
        );
        ";
        $db->exec($sql);
    }

    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS journal_entries, payments, invoice_items, invoices, chart_of_accounts;");
    }
}
'@
Set-Content -Path $financeMigration -Value $financeContent -Encoding UTF8

Write-Host "Database migration files generated successfully."
