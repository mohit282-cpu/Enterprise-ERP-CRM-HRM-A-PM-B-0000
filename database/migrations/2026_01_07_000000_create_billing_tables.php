<?php
class CreateBillingTables {
    public function up($db) {
        $sql = "
        CREATE TABLE receipts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            receipt_number VARCHAR(100) NOT NULL UNIQUE,
            payment_id INT NOT NULL,
            customer_id INT NOT NULL,
            amount DECIMAL(15,4) NOT NULL,
            issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE,
            FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
        );

        CREATE TABLE refunds (
            id INT AUTO_INCREMENT PRIMARY KEY,
            payment_id INT NOT NULL,
            amount DECIMAL(15,4) NOT NULL,
            reason TEXT,
            processed_by INT,
            processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE RESTRICT,
            FOREIGN KEY (processed_by) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE invoice_templates (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            html_content LONGTEXT,
            css_content LONGTEXT,
            is_default BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        ";
        $db->exec($sql);
    }
    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS invoice_templates, refunds, receipts;");
    }
}
