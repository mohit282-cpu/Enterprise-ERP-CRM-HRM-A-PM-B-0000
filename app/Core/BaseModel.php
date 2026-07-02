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