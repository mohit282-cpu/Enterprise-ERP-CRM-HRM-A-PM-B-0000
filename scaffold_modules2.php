<?php
$basePath = __DIR__;

$modulesConfig = [
    'CRM' => ['namespace' => 'Modules\CRM', 'controllerClass' => 'LeadController', 'serviceClass' => 'LeadService', 'repositoryClass' => 'LeadRepository', 'table' => 'crm_leads', 'view' => 'leads/index', 'dataKey' => 'leads'],
    'Reports' => ['namespace' => 'Modules\Reports', 'controllerClass' => 'ReportsController', 'serviceClass' => 'ReportService', 'repositoryClass' => 'ReportRepository', 'table' => 'reports', 'view' => 'index', 'dataKey' => 'reports']
];

foreach ($modulesConfig as $moduleName => $config) {
    $moduleDir = $basePath . '/modules/' . $moduleName;
    
    @mkdir($moduleDir . '/Repositories', 0777, true);
    @mkdir($moduleDir . '/Services', 0777, true);
    @mkdir($moduleDir . '/Controllers', 0777, true);
    
    $ns = $config['namespace'];
    $repo = $config['repositoryClass'];
    $svc = $config['serviceClass'];
    $ctrl = $config['controllerClass'];
    $tbl = $config['table'];
    $view = $config['view'];
    $dk = $config['dataKey'];
    
    $repoCode = "<?php
namespace {$ns}\\Repositories;

use App\\Core\\BaseRepository;
use App\\Core\\Database;
use App\\Core\\TenantContext;
use PDO;

class {$repo} extends BaseRepository {
    public function getAll() {
        \$db = Database::getInstance();
        try {
            \$tenantId = TenantContext::getInstance()->getTenantId();
            // If table doesn't exist yet (like reports), just return empty array
            \$stmt = \$db->prepare(\"SELECT * FROM {$tbl} WHERE tenant_id = ? ORDER BY id DESC\");
            \$stmt->execute([\$tenantId]);
            return \$stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (\\Exception \$e) {
            return [];
        }
    }
}
";
    file_put_contents($moduleDir . '/Repositories/' . $repo . '.php', $repoCode);

    $serviceCode = "<?php
namespace {$ns}\\Services;

use App\\Core\\BaseService;
use {$ns}\\Repositories\\{$repo};

class {$svc} extends BaseService {
    private {$repo} \$repo;
    
    public function __construct({$repo} \$repo) {
        \$this->repo = \$repo;
    }
    
    public function getAllRecords() {
        return \$this->repo->getAll();
    }
}
";
    file_put_contents($moduleDir . '/Services/' . $svc . '.php', $serviceCode);

    $controllerCode = "<?php
namespace {$ns}\\Controllers;

use App\\Core\\BaseController;
use {$ns}\\Services\\{$svc};

class {$ctrl} extends BaseController {
    private {$svc} \$service;
    
    public function __construct({$svc} \$service) {
        \$this->service = \$service;
    }
    
    public function index() {
        \$data = \$this->service->getAllRecords();
        return \$this->view('{$view}', ['{$dk}' => \$data], '{$moduleName}');
    }
}
";
    file_put_contents($moduleDir . '/Controllers/' . $ctrl . '.php', $controllerCode);
}
echo "Scaffolded MVC logic for CRM and Reports.\n";
