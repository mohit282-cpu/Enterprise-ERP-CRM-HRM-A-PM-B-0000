<?php
namespace App\Core;
use PDO;

class TenantMiddleware {
    public static function handle() {
        $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
        $parts = explode('.', $host);
        
        $subdomain = 'default';
        if (count($parts) > 1 && $host !== 'localhost:8000') {
            $subdomain = $parts[0];
        } else {
            // Local fallback
            $subdomain = 'acme';
        }
        
        $db = Database::getInstance();
        $stmt = $db->prepare("SELECT id, name FROM tenants WHERE subdomain = ? LIMIT 1");
        $stmt->execute([$subdomain]);
        $tenantData = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($tenantData) {
            TenantContext::getInstance()->setTenant($tenantData['id'], $tenantData['name'], $subdomain);
        } else {
            http_response_code(404);
            die("Tenant not found for subdomain: " . htmlspecialchars($subdomain));
        }
    }
}