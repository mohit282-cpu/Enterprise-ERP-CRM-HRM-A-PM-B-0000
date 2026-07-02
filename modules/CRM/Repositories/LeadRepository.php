<?php
namespace Modules\CRM\Repositories;

use App\Core\Database;
use App\Core\TenantContext;
use PDO;

class LeadRepository {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    public function getAll() {
        $tenantId = TenantContext::getInstance()->getTenantId();
        $stmt = $this->db->prepare("SELECT * FROM crm_leads WHERE tenant_id = ? ORDER BY created_at DESC");
        $stmt->execute([$tenantId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function create(array $data) {
        $tenantId = TenantContext::getInstance()->getTenantId();
        $stmt = $this->db->prepare("
            INSERT INTO crm_leads (tenant_id, name, company, email, phone, source, expected_revenue, stage, notes) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        return $stmt->execute([
            $tenantId,
            $data['name'] ?? '',
            $data['company'] ?? null,
            $data['email'] ?? '',
            $data['phone'] ?? null,
            $data['source'] ?? 'Organic',
            $data['expected_revenue'] ?? 0.00,
            $data['stage'] ?? 'New',
            $data['notes'] ?? null
        ]);
    }

    public function update(int $id, array $data) {
        $tenantId = TenantContext::getInstance()->getTenantId();
        $stmt = $this->db->prepare("
            UPDATE crm_leads 
            SET name=?, company=?, email=?, phone=?, source=?, expected_revenue=?, stage=?, notes=? 
            WHERE id=? AND tenant_id=?
        ");
        return $stmt->execute([
            $data['name'] ?? '',
            $data['company'] ?? null,
            $data['email'] ?? '',
            $data['phone'] ?? null,
            $data['source'] ?? 'Organic',
            $data['expected_revenue'] ?? 0.00,
            $data['stage'] ?? 'New',
            $data['notes'] ?? null,
            $id,
            $tenantId
        ]);
    }

    public function delete(int $id) {
        $tenantId = TenantContext::getInstance()->getTenantId();
        $stmt = $this->db->prepare("DELETE FROM crm_leads WHERE id=? AND tenant_id=?");
        return $stmt->execute([$id, $tenantId]);
    }
}