<?php
namespace Modules\CRM\Repositories;

use App\Core\BaseRepository;
use App\Core\Database;
use App\Core\TenantContext;
use PDO;

class LeadRepository extends BaseRepository {
    public function getAll() {
        $db = Database::getInstance();
        try {
            $tenantId = TenantContext::getInstance()->getTenantId();
            // If table doesn't exist yet (like reports), just return empty array
            $stmt = $db->prepare("SELECT * FROM crm_leads WHERE tenant_id = ? ORDER BY id DESC");
            $stmt->execute([$tenantId]);
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (\Exception $e) {
            return [];
        }
    }

    public function create(array $data) {
        $db = Database::getInstance();
        $tenantId = TenantContext::getInstance()->getTenantId();
        $data['tenant_id'] = $tenantId;
        
        $columns = implode(', ', array_keys($data));
        $placeholders = implode(', ', array_fill(0, count($data), '?'));
        
        $stmt = $db->prepare("INSERT INTO crm_leads ($columns) VALUES ($placeholders)");
        return $stmt->execute(array_values($data));
    }
}
