<?php

class AuthSeeder {
    public function run($db) {
        // Seed Root Company
        $db->exec("INSERT INTO companies (name) VALUES ('Sovryx Tech')");
        $companyId = $db->lastInsertId();

        // Seed Roles
        $db->exec("INSERT INTO roles (name, slug) VALUES ('Super Admin', 'super_admin')");
        $roleId = $db->lastInsertId();

        // Seed Root User
        $hashed = password_hash('Admin@123', PASSWORD_ARGON2ID);
        $uuid = bin2hex(random_bytes(16));
        $stmt = $db->prepare("INSERT INTO users (uuid, first_name, last_name, email, password, role_id, company_id) VALUES (?, 'System', 'Admin', 'admin@sovryx.com', ?, ?, ?)");
        $stmt->execute([$uuid, $hashed, $roleId, $companyId]);
        
        echo "AuthSeeder executed successfully. Default login: admin@sovryx.com / Admin@123\n";
    }
}
