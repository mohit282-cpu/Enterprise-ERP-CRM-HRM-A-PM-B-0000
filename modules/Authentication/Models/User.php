<?php

namespace Modules\Authentication\Models;

use App\Core\BaseModel;
use PDO;

class User extends BaseModel {
    protected string $table = 'users';

    public function findByEmail(string $email): ?array {
        $stmt = $this->db->prepare("SELECT * FROM {$this->table} WHERE email = :email LIMIT 1");
        $stmt->execute(['email' => $email]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    public function updateLastLogin(int $userId): void {
        $stmt = $this->db->prepare("UPDATE {$this->table} SET last_login = NOW() WHERE id = :id");
        $stmt->execute(['id' => $userId]);
    }
    
    public function hasPermission(int $userId, string $permissionSlug): bool {
        $stmt = $this->db->prepare("
            SELECT p.id FROM permissions p
            JOIN role_permissions rp ON p.id = rp.permission_id
            JOIN users u ON u.role_id = rp.role_id
            WHERE u.id = :user_id AND p.slug = :slug
        ");
        $stmt->execute(['user_id' => $userId, 'slug' => $permissionSlug]);
        return (bool)$stmt->fetch();
    }
}
