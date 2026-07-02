<?php
$basePath = __DIR__;

$modulesConfig = [
    'Projects' => ['namespace' => 'Modules\Projects', 'controllerClass' => 'ProjectController', 'serviceClass' => 'ProjectService', 'repositoryClass' => 'ProjectRepository', 'table' => 'projects', 'view' => 'projects/index', 'dataKey' => 'projects'],
    'HRM' => ['namespace' => 'Modules\HRM', 'controllerClass' => 'EmployeeController', 'serviceClass' => 'EmployeeService', 'repositoryClass' => 'EmployeeRepository', 'table' => 'employees', 'view' => 'employees/index', 'dataKey' => 'employees'],
    'Accounting' => ['namespace' => 'Modules\Accounting', 'controllerClass' => 'DashboardController', 'serviceClass' => 'AccountService', 'repositoryClass' => 'AccountRepository', 'table' => 'accounts', 'view' => 'dashboard/index', 'dataKey' => 'accounts'],
    'Billing' => ['namespace' => 'Modules\Billing', 'controllerClass' => 'InvoiceController', 'serviceClass' => 'InvoiceService', 'repositoryClass' => 'InvoiceRepository', 'table' => 'invoices', 'view' => 'invoices/index', 'dataKey' => 'invoices'],
    'Inventory' => ['namespace' => 'Modules\Inventory', 'controllerClass' => 'ProductController', 'serviceClass' => 'ProductService', 'repositoryClass' => 'ProductRepository', 'table' => 'products', 'view' => 'products/index', 'dataKey' => 'products'],
    'Hosting' => ['namespace' => 'Modules\Hosting', 'controllerClass' => 'AccountController', 'serviceClass' => 'HostingService', 'repositoryClass' => 'HostingRepository', 'table' => 'hosting_accounts', 'view' => 'accounts/index', 'dataKey' => 'accounts'],
    'Domains' => ['namespace' => 'Modules\Domains', 'controllerClass' => 'DomainController', 'serviceClass' => 'DomainService', 'repositoryClass' => 'DomainRepository', 'table' => 'domain_names', 'view' => 'domains/index', 'dataKey' => 'domains']
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
        \$tenantId = TenantContext::getInstance()->getTenantId();
        \$stmt = \$db->prepare(\"SELECT * FROM {$tbl} WHERE tenant_id = ? ORDER BY id DESC\");
        \$stmt->execute([\$tenantId]);
        return \$stmt->fetchAll(PDO::FETCH_ASSOC);
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
echo "Scaffolded MVC logic for all active modules.\n";
