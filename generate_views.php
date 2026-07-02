<?php
$basePath = __DIR__;

$modulesConfig = [
    'Projects' => ['viewPath' => 'projects/index.php', 'dataKey' => 'projects', 'title' => 'Projects', 'cols' => ['Name' => 'name', 'Status' => 'status', 'Progress' => 'progress']],
    'HRM' => ['viewPath' => 'employees/index.php', 'dataKey' => 'employees', 'title' => 'Employees', 'cols' => ['First Name' => 'first_name', 'Last Name' => 'last_name', 'Department' => 'department', 'Role' => 'role']],
    'Accounting' => ['viewPath' => 'dashboard/index.php', 'dataKey' => 'accounts', 'title' => 'Chart of Accounts', 'cols' => ['Account Name' => 'name', 'Type' => 'type', 'Balance' => 'balance']],
    'Billing' => ['viewPath' => 'invoices/index.php', 'dataKey' => 'invoices', 'title' => 'Invoices', 'cols' => ['Client' => 'client_name', 'Amount' => 'amount', 'Status' => 'status', 'Due Date' => 'due_date']],
    'Inventory' => ['viewPath' => 'products/index.php', 'dataKey' => 'products', 'title' => 'Inventory Products', 'cols' => ['Product Name' => 'name', 'SKU' => 'sku', 'Price' => 'price', 'Stock' => 'stock']],
    'Hosting' => ['viewPath' => 'accounts/index.php', 'dataKey' => 'accounts', 'title' => 'Hosting Accounts', 'cols' => ['Domain' => 'domain', 'Plan' => 'plan', 'Status' => 'status']],
    'Domains' => ['viewPath' => 'domains/index.php', 'dataKey' => 'domains', 'title' => 'Domain Names', 'cols' => ['Domain' => 'name', 'Registrar' => 'registrar', 'Expiry' => 'expiry_date', 'Status' => 'status']]
];

foreach ($modulesConfig as $module => $config) {
    $fullPath = $basePath . '/modules/' . $module . '/Views/' . $config['viewPath'];
    @mkdir(dirname($fullPath), 0777, true);
    
    $headers = '';
    foreach ($config['cols'] as $label => $key) {
        $headers .= "<th>{$label}</th>\n";
    }
    
    $cells = '';
    foreach ($config['cols'] as $label => $key) {
        $cells .= "<td><?= htmlspecialchars(\$row['{$key}'] ?? '') ?></td>\n";
    }
    
    $html = <<<HTML
<div class="row mb-4">
    <div class="col-12 d-flex justify-content-between align-items-center">
        <h4 class="fw-bold tracking-tight mb-0">{$config['title']}</h4>
        <button class="btn btn-primary"><i class="fas fa-plus me-2"></i> Add New</button>
    </div>
</div>

<div class="card shadow-sm border-0">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="bg-light">
                    <tr>
                        <th class="ps-4">ID</th>
                        {$headers}
                        <th class="text-end pe-4">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if(!empty(\${$config['dataKey']})): foreach(\${$config['dataKey']} as \$row): ?>
                    <tr>
                        <td class="ps-4">#<?= htmlspecialchars(\$row['id'] ?? '') ?></td>
                        {$cells}
                        <td class="text-end pe-4">
                            <button class="btn btn-sm btn-light text-primary me-1"><i class="fas fa-edit"></i></button>
                            <button class="btn btn-sm btn-light text-danger"><i class=\"fas fa-trash\"></i></button>
                        </td>
                    </tr>
                    <?php endforeach; else: ?>
                    <tr>
                        <td colspan="10" class="text-center py-5 text-muted">
                            <i class="fas fa-inbox fa-3x mb-3 opacity-25"></i>
                            <p class="mb-0">No records found.</p>
                        </td>
                    </tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>
HTML;

    file_put_contents($fullPath, $html);
    echo "Generated view for {$module}\n";
}
