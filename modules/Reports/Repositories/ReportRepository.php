<?php
namespace Modules\Reports\Repositories;

use App\Core\BaseRepository;
use App\Core\Database;
use App\Core\TenantContext;
use PDO;

class ReportRepository extends BaseRepository {
    public function getAll() {
        $db = Database::getInstance();
        try {
            $tenantId = TenantContext::getInstance()->getTenantId();
            // If table doesn't exist yet (like reports), just return empty array
            $stmt = $db->prepare("SELECT * FROM reports WHERE tenant_id = ? ORDER BY id DESC");
            $stmt->execute([$tenantId]);
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (\Exception $e) {
            return [];
        }
    }
}
