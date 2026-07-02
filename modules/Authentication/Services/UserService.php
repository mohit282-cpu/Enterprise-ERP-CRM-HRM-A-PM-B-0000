<?php

namespace Modules\Authentication\Services;

use Modules\Authentication\Models\User;
use PDO;

class UserService {
    private User $userModel;

    public function __construct(User $userModel) {
        $this->userModel = $userModel;
    }

    public function getAllUsers(): array {
        $stmt = $this->userModel->getDb()->query("SELECT id, first_name, last_name, email, status, created_at FROM users");
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    public function getUserById(int $id): ?array {
        $stmt = $this->userModel->getDb()->prepare("SELECT id, first_name, last_name, email, phone, status, 2fa_enabled FROM users WHERE id = :id");
        $stmt->execute(['id' => $id]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }
    
    public function updateUser(int $id, array $data): bool {
        // Implementation for updating a user
        return true;
    }
    
    public function deleteUser(int $id): bool {
        // Implementation for soft deleting a user
        return true;
    }
}
