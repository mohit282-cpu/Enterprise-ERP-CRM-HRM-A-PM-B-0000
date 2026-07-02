<?php
namespace Modules\Security\Controllers;
use App\Core\BaseController;
use App\Core\Database;
use PDO;

class SecurityCenterController extends BaseController {
    
    public function index() {
        return $this->view('dashboard/index', [], 'Security');
    }

    public function auditLogs() {
        $db = Database::getInstance()->getConnection();
        $stmt = $db->query("
            SELECT a.*, u.username 
            FROM audit_logs a 
            LEFT JOIN users u ON a.user_id = u.id 
            ORDER BY a.created_at DESC LIMIT 100
        ");
        $logs = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        return $this->view('audit_logs/index', ['logs' => $logs], 'Security');
    }
}
