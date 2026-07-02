<?php

namespace App\Http\Middleware;

use Modules\Authentication\Models\User;

class CheckPermission {
    public function handle(string $permissionSlug) {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }

        $userId = $_SESSION['user_id'] ?? null;
        if (!$userId) {
            header('Location: /login');
            exit;
        }

        $userModel = new User();
        if (!$userModel->hasPermission($userId, $permissionSlug)) {
            header('HTTP/1.0 403 Forbidden');
            echo "403 Forbidden - You do not have the required permission.";
            exit;
        }
    }
}
