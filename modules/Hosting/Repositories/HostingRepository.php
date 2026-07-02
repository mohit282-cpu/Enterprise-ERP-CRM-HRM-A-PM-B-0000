<?php
namespace Modules\Hosting\Repositories;

use App\Core\BaseRepository;
use App\Core\Database;
use App\Core\TenantContext;
use PDO;

class HostingRepository extends BaseRepository {
    public function getAll() {
        $db = Database::getInstance();
        $tenantId = TenantContext::getInstance()->getTenantId();
        $stmt = $db->prepare("SELECT * FROM hosting_accounts WHERE tenant_id = ? ORDER BY id DESC");
        $stmt->execute([$tenantId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function create(array $data) {
        $db = Database::getInstance();
        $tenantId = TenantContext::getInstance()->getTenantId();
        $data['tenant_id'] = $tenantId;
        
        $columns = implode(', ', array_keys($data));
        $placeholders = implode(', ', array_fill(0, count($data), '?'));
        
        $stmt = $db->prepare("INSERT INTO hosting_accounts ($columns) VALUES ($placeholders)");
        return $stmt->execute(array_values($data));
    }

    public function update(int $id, array $data) {
        $db = Database::getInstance();
        $tenantId = TenantContext::getInstance()->getTenantId();
        
        $setClauses = [];
        foreach ($data as $key => $val) {
            $setClauses[] = "$key = ?";
        }
        $setString = implode(', ', $setClauses);
        
        $stmt = $db->prepare("UPDATE hosting_accounts SET $setString WHERE id = ? AND tenant_id = ?");
        $values = array_values($data);
        $values[] = $id;
        $values[] = $tenantId;
        
        return $stmt->execute($values);
    }
    
    public function delete(int $id) {
        $db = Database::getInstance();
        $tenantId = TenantContext::getInstance()->getTenantId();
        $stmt = $db->prepare("DELETE FROM hosting_accounts WHERE id = ? AND tenant_id = ?");
        return $stmt->execute([$id, $tenantId]);
    }
}
