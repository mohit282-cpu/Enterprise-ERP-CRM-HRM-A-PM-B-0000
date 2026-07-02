<?php
class CreateDomainsTables {
    public function up($db) {
        $sql = "
        CREATE TABLE registrars (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(150) NOT NULL,
            api_key VARCHAR(255),
            api_secret VARCHAR(255),
            support_url VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE domains (
            id INT AUTO_INCREMENT PRIMARY KEY,
            contact_id INT NOT NULL,
            registrar_id INT,
            domain_name VARCHAR(255) NOT NULL UNIQUE,
            registration_date DATE,
            expiry_date DATE NOT NULL,
            auto_renew BOOLEAN DEFAULT FALSE,
            status ENUM('active', 'expired', 'pending_transfer', 'client_hold') DEFAULT 'active',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE RESTRICT,
            FOREIGN KEY (registrar_id) REFERENCES registrars(id) ON DELETE SET NULL
        );

        CREATE TABLE dns_records (
            id INT AUTO_INCREMENT PRIMARY KEY,
            domain_id INT NOT NULL,
            type ENUM('A', 'AAAA', 'CNAME', 'MX', 'TXT', 'NS', 'SRV') NOT NULL,
            name VARCHAR(255) NOT NULL,
            content TEXT NOT NULL,
            ttl INT DEFAULT 3600,
            priority INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE
        );

        CREATE TABLE ssl_certificates (
            id INT AUTO_INCREMENT PRIMARY KEY,
            domain_id INT NOT NULL,
            provider VARCHAR(100),
            issue_date DATE,
            expiry_date DATE NOT NULL,
            is_wildcard BOOLEAN DEFAULT FALSE,
            status ENUM('active', 'expired', 'revoked') DEFAULT 'active',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE
        );
        ";
        $db->exec($sql);
    }
    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS ssl_certificates, dns_records, domains, registrars;");
    }
}
