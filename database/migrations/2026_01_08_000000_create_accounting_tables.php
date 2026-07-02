<?php
class CreateAccountingTables {
    public function up($db) {
        $sql = "
        -- Drop old basic table if it exists (from initial Master Data)
        DROP TABLE IF EXISTS journal_entries;
        
        CREATE TABLE financial_years (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(50) NOT NULL,
            start_date DATE NOT NULL,
            end_date DATE NOT NULL,
            is_closed BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE journal_entries (
            id INT AUTO_INCREMENT PRIMARY KEY,
            reference_number VARCHAR(100) NOT NULL UNIQUE,
            description TEXT,
            entry_date DATE NOT NULL,
            total_amount DECIMAL(15,4) NOT NULL DEFAULT 0.0000,
            status ENUM('draft', 'posted', 'voided') DEFAULT 'draft',
            created_by INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE journal_entry_lines (
            id INT AUTO_INCREMENT PRIMARY KEY,
            journal_entry_id INT NOT NULL,
            account_id INT NOT NULL,
            description VARCHAR(255),
            debit DECIMAL(15,4) NOT NULL DEFAULT 0.0000,
            credit DECIMAL(15,4) NOT NULL DEFAULT 0.0000,
            FOREIGN KEY (journal_entry_id) REFERENCES journal_entries(id) ON DELETE CASCADE,
            FOREIGN KEY (account_id) REFERENCES chart_of_accounts(id) ON DELETE RESTRICT
        );
        ";
        $db->exec($sql);
    }
    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS journal_entry_lines, journal_entries, financial_years;");
    }
}
