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