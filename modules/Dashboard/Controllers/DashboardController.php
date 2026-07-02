<?php
namespace Modules\Dashboard\Controllers;

use App\Core\BaseController;

class DashboardController extends BaseController {
    public function __construct() {
        // Dashboard doesn't need a specific service yet
    }
    
    public function index() {
        $db = \App\Core\Database::getInstance();
        $tenantId = \App\Core\TenantContext::getInstance()->getTenantId();
        
        // Fetch Live Metrics
        $leadsCount = $db->query("SELECT COUNT(*) FROM crm_leads WHERE tenant_id = $tenantId")->fetchColumn();
        $projectsCount = $db->query("SELECT COUNT(*) FROM projects WHERE tenant_id = $tenantId")->fetchColumn();
        $employeesCount = $db->query("SELECT COUNT(*) FROM employees WHERE tenant_id = $tenantId")->fetchColumn();
        $invoicesSum = $db->query("SELECT SUM(amount) FROM invoices WHERE tenant_id = $tenantId")->fetchColumn();
        
        $metrics = [
            ['id' => 1, 'name' => 'Total Invoiced', 'value' => '$' . number_format((float)$invoicesSum, 2)],
            ['id' => 2, 'name' => 'Active Projects', 'value' => $projectsCount],
            ['id' => 3, 'name' => 'Total Leads', 'value' => $leadsCount],
            ['id' => 4, 'name' => 'Employees', 'value' => $employeesCount]
        ];
        return $this->view('index', ['metrics' => $metrics], 'Dashboard');
    }
}
