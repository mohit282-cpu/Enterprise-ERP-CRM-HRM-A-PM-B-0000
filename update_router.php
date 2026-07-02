<?php
$routerPath = __DIR__ . '/app/Core/Router.php';
$content = file_get_contents($routerPath);

// Define exactly what the new routes array should look like.
$newRoutes = <<<PHP
        \$routes = [
            '/login' => [
                'GET' => ['controller' => 'Modules\Security\Controllers\AuthController', 'method' => 'loginView', 'module' => 'Security'],
                'POST' => ['controller' => 'Modules\Security\Controllers\AuthController', 'method' => 'login', 'module' => 'Security']
            ],
            '/logout' => [
                'GET' => ['controller' => 'Modules\Security\Controllers\AuthController', 'method' => 'logout', 'module' => 'Security'],
            ],
            '/dashboard' => [
                'GET' => ['controller' => 'Modules\Dashboard\Controllers\DashboardController', 'method' => 'index', 'module' => 'Dashboard'],
            ],
            '/crm/leads' => [
                'GET' => ['controller' => 'Modules\CRM\Controllers\LeadController', 'method' => 'index', 'module' => 'CRM'],
                'POST' => ['controller' => 'Modules\CRM\Controllers\LeadController', 'method' => 'store', 'module' => 'CRM']
            ],
            '/crm/leads/update' => [
                'POST' => ['controller' => 'Modules\CRM\Controllers\LeadController', 'method' => 'update', 'module' => 'CRM']
            ],
            '/crm/leads/delete' => [
                'POST' => ['controller' => 'Modules\CRM\Controllers\LeadController', 'method' => 'destroy', 'module' => 'CRM']
            ],
            '/projects' => [
                'GET' => ['controller' => 'Modules\Projects\Controllers\ProjectController', 'method' => 'index', 'module' => 'Projects'],
                'POST' => ['controller' => 'Modules\Projects\Controllers\ProjectController', 'method' => 'store', 'module' => 'Projects']
            ],
            '/projects/update' => [
                'POST' => ['controller' => 'Modules\Projects\Controllers\ProjectController', 'method' => 'update', 'module' => 'Projects']
            ],
            '/projects/delete' => [
                'POST' => ['controller' => 'Modules\Projects\Controllers\ProjectController', 'method' => 'destroy', 'module' => 'Projects']
            ],
            '/accounting' => [
                'GET' => ['controller' => 'Modules\Accounting\Controllers\DashboardController', 'method' => 'index', 'module' => 'Accounting'],
                'POST' => ['controller' => 'Modules\Accounting\Controllers\DashboardController', 'method' => 'store', 'module' => 'Accounting']
            ],
            '/accounting/update' => [
                'POST' => ['controller' => 'Modules\Accounting\Controllers\DashboardController', 'method' => 'update', 'module' => 'Accounting']
            ],
            '/accounting/delete' => [
                'POST' => ['controller' => 'Modules\Accounting\Controllers\DashboardController', 'method' => 'destroy', 'module' => 'Accounting']
            ],
            '/billing/invoices' => [
                'GET' => ['controller' => 'Modules\Billing\Controllers\InvoiceController', 'method' => 'index', 'module' => 'Billing'],
                'POST' => ['controller' => 'Modules\Billing\Controllers\InvoiceController', 'method' => 'store', 'module' => 'Billing']
            ],
            '/billing/invoices/update' => [
                'POST' => ['controller' => 'Modules\Billing\Controllers\InvoiceController', 'method' => 'update', 'module' => 'Billing']
            ],
            '/billing/invoices/delete' => [
                'POST' => ['controller' => 'Modules\Billing\Controllers\InvoiceController', 'method' => 'destroy', 'module' => 'Billing']
            ],
            '/hrm/employees' => [
                'GET' => ['controller' => 'Modules\HRM\Controllers\EmployeeController', 'method' => 'index', 'module' => 'HRM'],
                'POST' => ['controller' => 'Modules\HRM\Controllers\EmployeeController', 'method' => 'store', 'module' => 'HRM']
            ],
            '/hrm/employees/update' => [
                'POST' => ['controller' => 'Modules\HRM\Controllers\EmployeeController', 'method' => 'update', 'module' => 'HRM']
            ],
            '/hrm/employees/delete' => [
                'POST' => ['controller' => 'Modules\HRM\Controllers\EmployeeController', 'method' => 'destroy', 'module' => 'HRM']
            ],
            '/inventory' => [
                'GET' => ['controller' => 'Modules\Inventory\Controllers\ProductController', 'method' => 'index', 'module' => 'Inventory'],
                'POST' => ['controller' => 'Modules\Inventory\Controllers\ProductController', 'method' => 'store', 'module' => 'Inventory']
            ],
            '/inventory/update' => [
                'POST' => ['controller' => 'Modules\Inventory\Controllers\ProductController', 'method' => 'update', 'module' => 'Inventory']
            ],
            '/inventory/delete' => [
                'POST' => ['controller' => 'Modules\Inventory\Controllers\ProductController', 'method' => 'destroy', 'module' => 'Inventory']
            ],
            '/hosting/accounts' => [
                'GET' => ['controller' => 'Modules\Hosting\Controllers\AccountController', 'method' => 'index', 'module' => 'Hosting'],
                'POST' => ['controller' => 'Modules\Hosting\Controllers\AccountController', 'method' => 'store', 'module' => 'Hosting']
            ],
            '/hosting/accounts/update' => [
                'POST' => ['controller' => 'Modules\Hosting\Controllers\AccountController', 'method' => 'update', 'module' => 'Hosting']
            ],
            '/hosting/accounts/delete' => [
                'POST' => ['controller' => 'Modules\Hosting\Controllers\AccountController', 'method' => 'destroy', 'module' => 'Hosting']
            ],
            '/domains' => [
                'GET' => ['controller' => 'Modules\Domains\Controllers\DomainController', 'method' => 'index', 'module' => 'Domains'],
                'POST' => ['controller' => 'Modules\Domains\Controllers\DomainController', 'method' => 'store', 'module' => 'Domains']
            ],
            '/domains/update' => [
                'POST' => ['controller' => 'Modules\Domains\Controllers\DomainController', 'method' => 'update', 'module' => 'Domains']
            ],
            '/domains/delete' => [
                'POST' => ['controller' => 'Modules\Domains\Controllers\DomainController', 'method' => 'destroy', 'module' => 'Domains']
            ],
            '/reports' => [
                'GET' => ['controller' => 'Modules\Reports\Controllers\ReportsController', 'method' => 'index', 'module' => 'Reports']
            ],
            '/security' => [
                'GET' => ['controller' => 'Modules\Security\Controllers\SecurityCenterController', 'method' => 'index', 'module' => 'Security']
            ],
        ];
PHP;

$content = preg_replace('/\$routes = \[.*?\];/s', $newRoutes . ';', $content);
file_put_contents($routerPath, $content);
echo "Updated Router.php with update/delete routes.\n";
