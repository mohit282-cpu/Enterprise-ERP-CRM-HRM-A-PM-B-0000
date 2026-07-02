<?php

class CreateAuthTables {
    public function up($db) {
        $sql = "
        CREATE TABLE branches (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            location VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE departments (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            branch_id INT,
            FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE SET NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE roles (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            slug VARCHAR(100) NOT NULL UNIQUE,
            description TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE permissions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            module VARCHAR(100) NOT NULL,
            action VARCHAR(100) NOT NULL,
            name VARCHAR(100) NOT NULL,
            slug VARCHAR(100) NOT NULL UNIQUE
        );

        CREATE TABLE users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            uuid CHAR(36) NOT NULL UNIQUE,
            first_name VARCHAR(100) NOT NULL,
            last_name VARCHAR(100) NOT NULL,
            email VARCHAR(255) NOT NULL UNIQUE,
            password VARCHAR(255) NOT NULL,
            phone VARCHAR(50),
            status ENUM('active', 'suspended', 'deactivated') DEFAULT 'active',
            2fa_enabled BOOLEAN DEFAULT FALSE,
            two_factor_secret VARCHAR(255),
            branch_id INT,
            department_id INT,
            role_id INT,
            last_login TIMESTAMP NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE SET NULL,
            FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
            FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE SET NULL
        );

        CREATE TABLE role_permissions (
            role_id INT,
            permission_id INT,
            PRIMARY KEY (role_id, permission_id),
            FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
            FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
        );

        CREATE TABLE audit_logs (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            table_name VARCHAR(100) NOT NULL,
            record_id INT NOT NULL,
            before_value JSON,
            after_value JSON,
            changed_by INT,
            reason TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE sessions (
            id VARCHAR(255) PRIMARY KEY,
            user_id INT,
            ip_address VARCHAR(45),
            user_agent TEXT,
            payload TEXT,
            last_activity INT,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
        ";
        $db->exec($sql);
    }

    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS sessions, audit_logs, role_permissions, users, permissions, roles, departments, branches;");
    }
}
