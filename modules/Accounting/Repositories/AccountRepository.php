<?php
namespace Modules\Accounting\Repositories;

use App\Core\BaseRepository;
use App\Core\Database;
use App\Core\TenantContext;
use PDO;

class AccountRepository extends BaseRepository {
    public function getAll() {
        $db = Database::getInstance();
        $tenantId = TenantContext::getInstance()->getTenantId();
        $stmt = $db->prepare("SELECT * FROM accounts WHERE tenant_id = ? ORDER BY id DESC");
        $stmt->execute([$tenantId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
