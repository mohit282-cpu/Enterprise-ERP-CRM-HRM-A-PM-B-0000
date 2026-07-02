$basePath = "Z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"
$corePath = Join-Path $basePath "app\Core"

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# 1. Tenant Context
$tenantContextContent = @'
<?php
namespace App\Core;

class TenantContext {
    private static $instance = null;
    private ?int $tenantId = null;
    private ?string $tenantName = null;
    private ?string $subdomain = null;

    private function __construct() {}

    public static function getInstance(): self {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    public function setTenant(int $id, string $name, string $subdomain) {
        $this->tenantId = $id;
        $this->tenantName = $name;
        $this->subdomain = $subdomain;
    }

    public function getTenantId(): ?int {
        return $this->tenantId;
    }
    
    public function getTenantName(): ?string {
        return $this->tenantName;
    }
    
    public function isSuperAdmin(): bool {
        return $this->subdomain === 'admin' || $this->subdomain === 'master';
    }
}
'@
[System.IO.File]::WriteAllText((Join-Path $corePath "TenantContext.php"), $tenantContextContent, $utf8NoBom)


# 2. Tenant Middleware
$tenantMiddlewareContent = @'
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
'@
[System.IO.File]::WriteAllText((Join-Path $corePath "TenantMiddleware.php"), $tenantMiddlewareContent, $utf8NoBom)


# 3. Update BaseModel for Strict Scoping
$baseModelContent = @'
<?php
namespace App\Core;

use Exception;

abstract class BaseModel {
    protected string $table;
    protected $db;
    protected bool $isGlobal = false; // Set to true for tables like 'tenants' or 'subscriptions'
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function getTable(): string {
        return $this->table;
    }
    
    public function getDb() {
        return $this->db;
    }
    
    /**
     * Helper to automatically append tenant_id to WHERE clauses
     */
    protected function scopeTenant(string $query): string {
        if ($this->isGlobal) {
            return $query;
        }
        
        $tenantId = TenantContext::getInstance()->getTenantId();
        if ($tenantId === null) {
            throw new Exception("CRITICAL SECURITY: Cannot execute scoped query without an active Tenant Context.");
        }
        
        // Simplistic injection for mock purposes. Real ORMs build the AST.
        if (stripos($query, 'WHERE') !== false) {
            return str_ireplace('WHERE', "WHERE tenant_id = {$tenantId} AND ", $query);
        }
        
        return $query . " WHERE tenant_id = {$tenantId}";
    }
}
'@
[System.IO.File]::WriteAllText((Join-Path $corePath "BaseModel.php"), $baseModelContent, $utf8NoBom)

Write-Host "SaaS Core classes generated successfully."
