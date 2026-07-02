<?php
class CreateCrmTables {
    public function up($db) {
        $sql = "
        CREATE TABLE contacts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            customer_id INT NOT NULL,
            first_name VARCHAR(100) NOT NULL,
            last_name VARCHAR(100) NOT NULL,
            email VARCHAR(255),
            phone VARCHAR(50),
            position VARCHAR(100),
            is_primary BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
        );

        CREATE TABLE notes (
            id INT AUTO_INCREMENT PRIMARY KEY,
            model_type VARCHAR(50) NOT NULL, -- e.g., 'Lead', 'Customer'
            model_id INT NOT NULL,
            user_id INT NOT NULL,
            content TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );

        CREATE TABLE follow_ups (
            id INT AUTO_INCREMENT PRIMARY KEY,
            lead_id INT,
            customer_id INT,
            user_id INT NOT NULL,
            type ENUM('call', 'email', 'meeting') DEFAULT 'call',
            status ENUM('pending', 'completed', 'cancelled') DEFAULT 'pending',
            scheduled_at DATETIME NOT NULL,
            notes TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );

        CREATE TABLE quotations (
            id INT AUTO_INCREMENT PRIMARY KEY,
            quote_number VARCHAR(100) NOT NULL UNIQUE,
            customer_id INT,
            lead_id INT,
            subtotal DECIMAL(15,4) DEFAULT 0.0000,
            grand_total DECIMAL(15,4) DEFAULT 0.0000,
            status ENUM('draft', 'sent', 'accepted', 'rejected') DEFAULT 'draft',
            valid_until DATE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        );
        ";
        $db->exec($sql);
    }
    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS quotations, follow_ups, notes, contacts;");
    }
}
