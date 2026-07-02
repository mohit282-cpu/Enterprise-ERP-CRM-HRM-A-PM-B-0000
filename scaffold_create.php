<?php
$basePath = __DIR__;

$modulesConfig = [
    'Projects' => ['namespace' => 'Modules\Projects', 'controllerClass' => 'ProjectController', 'serviceClass' => 'ProjectService', 'repositoryClass' => 'ProjectRepository', 'table' => 'projects', 'viewPath' => 'projects/index.php', 'dataKey' => 'projects', 'title' => 'Projects', 'route' => '/projects', 'formCols' => ['name' => 'text', 'status' => 'text', 'progress' => 'number']],
    'HRM' => ['namespace' => 'Modules\HRM', 'controllerClass' => 'EmployeeController', 'serviceClass' => 'EmployeeService', 'repositoryClass' => 'EmployeeRepository', 'table' => 'employees', 'viewPath' => 'employees/index.php', 'dataKey' => 'employees', 'title' => 'Employees', 'route' => '/hrm/employees', 'formCols' => ['first_name' => 'text', 'last_name' => 'text', 'department' => 'text', 'role' => 'text']],
    'Accounting' => ['namespace' => 'Modules\Accounting', 'controllerClass' => 'DashboardController', 'serviceClass' => 'AccountService', 'repositoryClass' => 'AccountRepository', 'table' => 'accounts', 'viewPath' => 'dashboard/index.php', 'dataKey' => 'accounts', 'title' => 'Chart of Accounts', 'route' => '/accounting', 'formCols' => ['name' => 'text', 'type' => 'text', 'balance' => 'number']],
    'Billing' => ['namespace' => 'Modules\Billing', 'controllerClass' => 'InvoiceController', 'serviceClass' => 'InvoiceService', 'repositoryClass' => 'InvoiceRepository', 'table' => 'invoices', 'viewPath' => 'invoices/index.php', 'dataKey' => 'invoices', 'title' => 'Invoices', 'route' => '/billing/invoices', 'formCols' => ['client_name' => 'text', 'amount' => 'number', 'status' => 'text', 'due_date' => 'date']],
    'Inventory' => ['namespace' => 'Modules\Inventory', 'controllerClass' => 'ProductController', 'serviceClass' => 'ProductService', 'repositoryClass' => 'ProductRepository', 'table' => 'products', 'viewPath' => 'products/index.php', 'dataKey' => 'products', 'title' => 'Inventory', 'route' => '/inventory', 'formCols' => ['name' => 'text', 'sku' => 'text', 'price' => 'number', 'stock' => 'number']],
    'Hosting' => ['namespace' => 'Modules\Hosting', 'controllerClass' => 'AccountController', 'serviceClass' => 'HostingService', 'repositoryClass' => 'HostingRepository', 'table' => 'hosting_accounts', 'viewPath' => 'accounts/index.php', 'dataKey' => 'accounts', 'title' => 'Hosting Accounts', 'route' => '/hosting/accounts', 'formCols' => ['domain' => 'text', 'plan' => 'text', 'status' => 'text']],
    'Domains' => ['namespace' => 'Modules\Domains', 'controllerClass' => 'DomainController', 'serviceClass' => 'DomainService', 'repositoryClass' => 'DomainRepository', 'table' => 'domain_names', 'viewPath' => 'domains/index.php', 'dataKey' => 'domains', 'title' => 'Domain Names', 'route' => '/domains', 'formCols' => ['name' => 'text', 'registrar' => 'text', 'expiry_date' => 'date', 'status' => 'text']],
    'CRM' => ['namespace' => 'Modules\CRM', 'controllerClass' => 'LeadController', 'serviceClass' => 'LeadService', 'repositoryClass' => 'LeadRepository', 'table' => 'crm_leads', 'viewPath' => 'leads/index.php', 'dataKey' => 'leads', 'title' => 'CRM Leads', 'route' => '/crm/leads', 'formCols' => ['name' => 'text', 'company' => 'text', 'email' => 'email', 'stage' => 'text']]
];

foreach ($modulesConfig as $module => $config) {
    $moduleDir = $basePath . '/modules/' . $module;
    
    $ns = $config['namespace'];
    $repo = $config['repositoryClass'];
    $svc = $config['serviceClass'];
    $ctrl = $config['controllerClass'];
    $tbl = $config['table'];
    
    // 1. UPDATE REPOSITORY
    $repoContent = file_get_contents($moduleDir . '/Repositories/' . $repo . '.php');
    if (strpos($repoContent, 'public function create') === false) {
        $createMethod = "
    public function create(array \$data) {
        \$db = Database::getInstance();
        \$tenantId = TenantContext::getInstance()->getTenantId();
        \$data['tenant_id'] = \$tenantId;
        
        \$columns = implode(', ', array_keys(\$data));
        \$placeholders = implode(', ', array_fill(0, count(\$data), '?'));
        
        \$stmt = \$db->prepare(\"INSERT INTO {$tbl} (\$columns) VALUES (\$placeholders)\");
        return \$stmt->execute(array_values(\$data));
    }
}
";
        $repoContent = preg_replace('/}\s*$/', $createMethod, $repoContent);
        file_put_contents($moduleDir . '/Repositories/' . $repo . '.php', $repoContent);
    }
    
    // 2. UPDATE SERVICE
    $svcContent = file_get_contents($moduleDir . '/Services/' . $svc . '.php');
    if (strpos($svcContent, 'public function createRecord') === false) {
        $createMethod = "
    public function createRecord(array \$data) {
        return \$this->repo->create(\$data);
    }
}
";
        $svcContent = preg_replace('/}\s*$/', $createMethod, $svcContent);
        file_put_contents($moduleDir . '/Services/' . $svc . '.php', $svcContent);
    }
    
    // 3. UPDATE CONTROLLER
    $ctrlContent = file_get_contents($moduleDir . '/Controllers/' . $ctrl . '.php');
    if (strpos($ctrlContent, 'public function store') === false) {
        $createMethod = "
    public function store() {
        if (\$_SERVER['REQUEST_METHOD'] === 'POST') {
            \$data = \$_POST;
            \$this->service->createRecord(\$data);
            header('Location: {$config['route']}');
            exit;
        }
    }
}
";
        $ctrlContent = preg_replace('/}\s*$/', $createMethod, $ctrlContent);
        file_put_contents($moduleDir . '/Controllers/' . $ctrl . '.php', $ctrlContent);
    }
    
    // 4. UPDATE VIEW (Inject Modal)
    $viewPath = $moduleDir . '/Views/' . $config['viewPath'];
    $viewContent = file_get_contents($viewPath);
    
    if (strpos($viewContent, 'id="addModal"') === false) {
        // Build form fields
        $formFields = '';
        foreach ($config['formCols'] as $name => $type) {
            $label = ucwords(str_replace('_', ' ', $name));
            $formFields .= "
                    <div class=\"mb-3\">
                        <label class=\"form-label fw-bold\">{$label}</label>
                        <input type=\"{$type}\" name=\"{$name}\" class=\"form-control\" required>
                    </div>";
        }
        
        $modalHtml = <<<HTML
<div class="modal fade" id="addModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <form method="POST" action="{$config['route']}">
            <div class="modal-content border-0 shadow-lg">
                <div class="modal-header bg-light border-0">
                    <h5 class="modal-title fw-bold">Add {$config['title']}</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    {$formFields}
                </div>
                <div class="modal-footer border-0 bg-light">
                    <button type="button" class="btn btn-link text-muted text-decoration-none" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary px-4">Save</button>
                </div>
            </div>
        </form>
    </div>
</div>
HTML;
        
        // Update Add New button
        $viewContent = str_replace('<button class="btn btn-primary"><i class="fas fa-plus me-2"></i> Add New</button>', 
                                  '<button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addModal"><i class="fas fa-plus me-2"></i> Add New</button>', 
                                  $viewContent);
                                  
        // Append modal to end of file
        $viewContent .= "\n" . $modalHtml;
        file_put_contents($viewPath, $viewContent);
    }
}

echo "Scaffolded Create logic for all modules.\n";
