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
