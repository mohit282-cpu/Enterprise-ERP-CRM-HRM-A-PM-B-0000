<?php
class CreateHostingTables {
    public function up($db) {
        $sql = "
        CREATE TABLE servers (
            id INT AUTO_INCREMENT PRIMARY KEY,
            hostname VARCHAR(255) NOT NULL UNIQUE,
            ip_address VARCHAR(45) NOT NULL,
            datacenter VARCHAR(100),
            control_panel ENUM('cpanel', 'plesk', 'directadmin', 'custom') DEFAULT 'cpanel',
            api_token VARCHAR(255),
            status ENUM('active', 'maintenance', 'offline') DEFAULT 'active',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE hosting_plans (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(150) NOT NULL,
            disk_space_mb INT NOT NULL,
            bandwidth_mb INT NOT NULL,
            annual_price DECIMAL(15,4) NOT NULL,
            is_active BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE hosting_accounts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            contact_id INT NOT NULL,
            server_id INT NOT NULL,
            hosting_plan_id INT NOT NULL,
            domain_name VARCHAR(255) NOT NULL UNIQUE,
            username VARCHAR(50) NOT NULL,
            password_hash VARCHAR(255),
            next_renewal_date DATE NOT NULL,
            status ENUM('active', 'suspended', 'terminated', 'pending_setup') DEFAULT 'pending_setup',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE RESTRICT,
            FOREIGN KEY (server_id) REFERENCES servers(id) ON DELETE RESTRICT,
            FOREIGN KEY (hosting_plan_id) REFERENCES hosting_plans(id) ON DELETE RESTRICT
        );

        CREATE TABLE hosting_usage (
            id INT AUTO_INCREMENT PRIMARY KEY,
            hosting_account_id INT NOT NULL,
            month_year VARCHAR(7) NOT NULL, -- Format YYYY-MM
            disk_used_mb INT DEFAULT 0,
            bandwidth_used_mb INT DEFAULT 0,
            recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (hosting_account_id) REFERENCES hosting_accounts(id) ON DELETE CASCADE,
            UNIQUE KEY account_month (hosting_account_id, month_year)
        );

        CREATE TABLE hosting_backups (
            id INT AUTO_INCREMENT PRIMARY KEY,
            hosting_account_id INT NOT NULL,
            status ENUM('success', 'failed', 'in_progress') NOT NULL,
            file_size_mb INT,
            completed_at TIMESTAMP,
            FOREIGN KEY (hosting_account_id) REFERENCES hosting_accounts(id) ON DELETE CASCADE
        );
        ";
        $db->exec($sql);
    }
    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS hosting_backups, hosting_usage, hosting_accounts, hosting_plans, servers;");
    }
}
