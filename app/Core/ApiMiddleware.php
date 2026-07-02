<?php
namespace App\Core;
use PDO;

class ApiMiddleware {
    /**
     * Validates Authorization: Bearer <token>
     */
    public static function authenticate() {
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? '';

        if (!preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
            self::abort(401, 'Unauthorized: Missing or Invalid Bearer Token');
        }

        $token = $matches[1];
        
        // Dummy check against db for Phase 1
        $db = Database::getInstance()->getConnection();
        $stmt = $db->prepare("SELECT id, user_id FROM api_keys WHERE api_key = ? AND is_active = 1");
        $stmt->execute([hash('sha256', $token)]);
        $keyRecord = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$keyRecord) {
            self::abort(401, 'Unauthorized: Invalid API Key');
        }

        // Token is valid. Update last used timestamp.
        $db->prepare("UPDATE api_keys SET last_used_at = NOW() WHERE id = ?")->execute([$keyRecord['id']]);

        // Inject user context globally
        $_SERVER['API_USER_ID'] = $keyRecord['user_id'];
    }

    private static function abort(int $code, string $message) {
        http_response_code($code);
        header('Content-Type: application/json');
        echo json_encode(['success' => false, 'message' => $message]);
        exit;
    }
}
