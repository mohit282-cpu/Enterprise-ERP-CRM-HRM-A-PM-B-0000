<?php
namespace App\Core;

class TenantMiddleware {
    public static function handle() {
        $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
        $parts = explode('.', $host);
        
        $subdomain = 'default';
        if (count($parts) > 1 && $host !== 'localhost:8000') {
            $subdomain = $parts[0]; // e.g., acme.sovryx.com -> acme
        }
        
        // In a real scenario, query the DB to resolve subdomain -> tenant_id
        // Mock DB Resolution:
        $mockTenants = [
            'acme' => ['id' => 1, 'name' => 'Acme Corp'],
            'stark' => ['id' => 2, 'name' => 'Stark Industries'],
            'admin' => ['id' => 0, 'name' => 'Super Admin']
        ];
        
        $tenantData = $mockTenants[$subdomain] ?? ['id' => 999, 'name' => 'Demo Tenant'];
        
        TenantContext::getInstance()->setTenant($tenantData['id'], $tenantData['name'], $subdomain);
    }
}