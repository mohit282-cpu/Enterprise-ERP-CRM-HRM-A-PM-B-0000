<?php

namespace Modules\Authentication\Services;

use Modules\Authentication\Models\User;
use Exception;

class AuthService {
    private User $userModel;

    public function __construct(User $userModel) {
        $this->userModel = $userModel;
    }

    public function login(string $email, string $password): array {
        $user = $this->userModel->findByEmail($email);
        
        if (!$user) {
            throw new Exception("Invalid credentials");
        }

        if ($user['status'] !== 'active') {
            throw new Exception("Account is not active");
        }

        if (!password_verify($password, $user['password'])) {
            // Track failed login logic here
            throw new Exception("Invalid credentials");
        }

        if ($user['2fa_enabled']) {
            return ['status' => '2fa_required', 'user_id' => $user['id']];
        }

        $this->startSession($user);
        return ['status' => 'success', 'user' => $user];
    }

    public function startSession(array $user): void {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
        
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['role_id'] = $user['role_id'];
        $_SESSION['last_activity'] = time();
        
        $this->userModel->updateLastLogin($user['id']);
    }

    public function logout(): void {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
        session_destroy();
    }
}
