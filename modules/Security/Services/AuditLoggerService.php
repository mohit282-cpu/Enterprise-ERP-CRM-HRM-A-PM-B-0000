<?php
namespace Modules\Security\Services;
use App\Core\Database;

class AuditLoggerService {
    public static function log(string $eventType, ?string $tableName = null, ?int $recordId = null, ?array $oldValues = null, ?array $newValues = null) {
        $db = Database::getInstance()->getConnection();
        $userId = $_SESSION['user_id'] ?? null;
        $ip = $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1';
        $agent = $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown';

        $stmt = $db->prepare("
            INSERT INTO audit_logs (user_id, event_type, table_name, record_id, old_values, new_values, ip_address, user_agent)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ");
        
        $oldJson = $oldValues ? json_encode($oldValues) : null;
        $newJson = $newValues ? json_encode($newValues) : null;

        $stmt->execute([$userId, $eventType, $tableName, $recordId, $oldJson, $newJson, $ip, $agent]);
    }
}
