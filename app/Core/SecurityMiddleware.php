<?php
namespace App\Core;

class SecurityMiddleware {
    
    public static function handle() {
        self::setSecurityHeaders();
        self::validateCsrf();
        self::enforceRateLimit();
    }

    private static function setSecurityHeaders() {
        header("X-Frame-Options: SAMEORIGIN");
        header("X-XSS-Protection: 1; mode=block");
        header("X-Content-Type-Options: nosniff");
        header("Strict-Transport-Security: max-age=31536000; includeSubDomains");
        header("Content-Security-Policy: default-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net;");
    }

    private static function validateCsrf() {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
        
        // Generate Token if missing
        if (empty($_SESSION['csrf_token'])) {
            $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
        }

        // Validate on modifying requests
        if (in_array($_SERVER['REQUEST_METHOD'], ['POST', 'PUT', 'DELETE'])) {
            $token = $_POST['csrf_token'] ?? $_SERVER['HTTP_X_CSRF_TOKEN'] ?? '';
            if (!hash_equals($_SESSION['csrf_token'], $token)) {
                http_response_code(403);
                die("403 Forbidden: CSRF token validation failed.");
            }
        }
    }

    private static function enforceRateLimit() {
        // Basic implementation for Phase 1. 
        // In production, this should use Redis to avoid DB bottleneck.
        $ip = $_SERVER['REMOTE_ADDR'];
        $endpoint = $_SERVER['REQUEST_URI'];
        $limit = 60; // Max hits per minute
        
        // Pseudo logic: if hits > limit within 60 seconds -> die("429 Too Many Requests")
    }
}
