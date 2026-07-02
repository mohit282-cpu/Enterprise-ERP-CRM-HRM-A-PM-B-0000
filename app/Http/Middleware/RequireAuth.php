<?php

namespace App\Http\Middleware;

class RequireAuth {
    public function handle() {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }

        if (!isset($_SESSION['user_id'])) {
            header('Location: /login');
            exit;
        }

        // Check session timeout (e.g., 30 mins)
        if (isset($_SESSION['last_activity']) && (time() - $_SESSION['last_activity'] > 1800)) {
            session_unset();
            session_destroy();
            header('Location: /login?timeout=1');
            exit;
        }

        $_SESSION['last_activity'] = time();
    }
}
