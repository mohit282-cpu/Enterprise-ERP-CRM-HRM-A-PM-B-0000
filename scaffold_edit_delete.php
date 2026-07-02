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
    if (strpos($repoContent, 'public function update') === false) {
        $updateMethod = "
    public function update(int \$id, array \$data) {
        \$db = Database::getInstance();
        \$tenantId = TenantContext::getInstance()->getTenantId();
        
        \$setClauses = [];
        foreach (\$data as \$key => \$val) {
            \$setClauses[] = \"\$key = ?\";
        }
        \$setString = implode(', ', \$setClauses);
        
        \$stmt = \$db->prepare(\"UPDATE {$tbl} SET \$setString WHERE id = ? AND tenant_id = ?\");
        \$values = array_values(\$data);
        \$values[] = \$id;
        \$values[] = \$tenantId;
        
        return \$stmt->execute(\$values);
    }
    
    public function delete(int \$id) {
        \$db = Database::getInstance();
        \$tenantId = TenantContext::getInstance()->getTenantId();
        \$stmt = \$db->prepare(\"DELETE FROM {$tbl} WHERE id = ? AND tenant_id = ?\");
        return \$stmt->execute([\$id, \$tenantId]);
    }
}
";
        $repoContent = preg_replace('/}\s*$/', $updateMethod, $repoContent);
        file_put_contents($moduleDir . '/Repositories/' . $repo . '.php', $repoContent);
    }
    
    // 2. UPDATE SERVICE
    $svcContent = file_get_contents($moduleDir . '/Services/' . $svc . '.php');
    if (strpos($svcContent, 'public function updateRecord') === false) {
        $updateMethod = "
    public function updateRecord(int \$id, array \$data) {
        return \$this->repo->update(\$id, \$data);
    }
    
    public function deleteRecord(int \$id) {
        return \$this->repo->delete(\$id);
    }
}
";
        $svcContent = preg_replace('/}\s*$/', $updateMethod, $svcContent);
        file_put_contents($moduleDir . '/Services/' . $svc . '.php', $svcContent);
    }
    
    // 3. UPDATE CONTROLLER
    $ctrlContent = file_get_contents($moduleDir . '/Controllers/' . $ctrl . '.php');
    if (strpos($ctrlContent, 'public function update') === false) {
        $updateMethod = "
    public function update() {
        if (\$_SERVER['REQUEST_METHOD'] === 'POST') {
            \$id = \$_POST['id'];
            unset(\$_POST['id']);
            \$this->service->updateRecord((int)\$id, \$_POST);
            header('Location: {$config['route']}');
            exit;
        }
    }
    
    public function destroy() {
        if (\$_SERVER['REQUEST_METHOD'] === 'POST') {
            \$id = \$_POST['id'];
            \$this->service->deleteRecord((int)\$id);
            header('Location: {$config['route']}');
            exit;
        }
    }
}
";
        $ctrlContent = preg_replace('/}\s*$/', $updateMethod, $ctrlContent);
        file_put_contents($moduleDir . '/Controllers/' . $ctrl . '.php', $ctrlContent);
    }
    
    // 4. UPDATE VIEW (Inject Edit Modal & Form Action wiring)
    $viewPath = $moduleDir . '/Views/' . $config['viewPath'];
    $viewContent = file_get_contents($viewPath);
    
    if (strpos($viewContent, 'id="editModal"') === false) {
        // Build edit form fields
        $formFields = '';
        foreach ($config['formCols'] as $name => $type) {
            $label = ucwords(str_replace('_', ' ', $name));
            $formFields .= "
                    <div class=\"mb-3\">
                        <label class=\"form-label fw-bold\">{$label}</label>
                        <input type=\"{$type}\" name=\"{$name}\" id=\"edit_{$name}\" class=\"form-control\" required>
                    </div>";
        }
        
        $modalHtml = <<<HTML
<div class="modal fade" id="editModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <form method="POST" action="{$config['route']}/update">
            <input type="hidden" name="id" id="edit_id">
            <div class="modal-content border-0 shadow-lg">
                <div class="modal-header bg-light border-0">
                    <h5 class="modal-title fw-bold">Edit {$config['title']}</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    {$formFields}
                </div>
                <div class="modal-footer border-0 bg-light">
                    <button type="button" class="btn btn-link text-muted text-decoration-none" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary px-4">Update</button>
                </div>
            </div>
        </form>
    </div>
</div>
HTML;
        
        // Update Action buttons in table
        $actions = <<<HTML
                            <button onclick='openEditModal(<?= json_encode(\$row) ?>)' class="btn btn-sm btn-light text-primary me-1"><i class="fas fa-edit"></i></button>
                            <form method="POST" action="{$config['route']}/delete" class="d-inline">
                                <input type="hidden" name="id" value="<?= \$row['id'] ?>">
                                <button type="submit" class="btn btn-sm btn-light text-danger" onclick="return confirm('Are you sure you want to delete this?')"><i class="fas fa-trash"></i></button>
                            </form>
HTML;
        
        // Replace old buttons
        $viewContent = preg_replace('/<td class="text-end pe-4">.*?<\/td>/s', '<td class="text-end pe-4">' . $actions . '</td>', $viewContent);
        
        // Add JS script for Edit Modal
        $jsMapping = "";
        foreach ($config['formCols'] as $name => $type) {
            $jsMapping .= "document.getElementById('edit_{$name}').value = row['{$name}'] || '';\n            ";
        }
        
        $jsHtml = <<<HTML
<script>
    function openEditModal(row) {
        document.getElementById('edit_id').value = row['id'];
        {$jsMapping}
        var editModal = new bootstrap.Modal(document.getElementById('editModal'));
        editModal.show();
    }
</script>
HTML;
        
        // Append modal and js to end of file
        $viewContent .= "\n" . $modalHtml . "\n" . $jsHtml;
        file_put_contents($viewPath, $viewContent);
    }
}

echo "Scaffolded Edit/Delete logic for all modules.\n";
