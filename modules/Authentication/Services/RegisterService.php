<?php

namespace Modules\Authentication\Services;

use Modules\Authentication\Models\User;
use Exception;
use PDO;

class RegisterService {
    private User $userModel;

    public function __construct(User $userModel) {
        $this->userModel = $userModel;
    }

    public function registerUser(array $data): void {
        if (empty($data['first_name']) || empty($data['last_name']) || empty($data['email']) || empty($data['password'])) {
            throw new Exception("All fields are required.");
        }

        if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            throw new Exception("Invalid email format.");
        }

        if (strlen($data['password']) < 8) {
            throw new Exception("Password must be at least 8 characters long.");
        }

        if ($data['password'] !== $data['password_confirm']) {
            throw new Exception("Passwords do not match.");
        }

        $existing = $this->userModel->findByEmail($data['email']);
        if ($existing) {
            throw new Exception("Email already exists.");
        }

        $hashedPassword = password_hash($data['password'], PASSWORD_ARGON2ID);
        $uuid = bin2hex(random_bytes(16)); // Basic UUID representation

        $stmt = $this->userModel->getDb()->prepare("
            INSERT INTO users (uuid, first_name, last_name, email, password, status)
            VALUES (:uuid, :first_name, :last_name, :email, :password, 'active')
        ");
        
        $stmt->execute([
            'uuid' => $uuid,
            'first_name' => $data['first_name'],
            'last_name' => $data['last_name'],
            'email' => $data['email'],
            'password' => $hashedPassword
        ]);
        
        // Dispatch UserCreatedEvent here in real app
    }
}
