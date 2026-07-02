<?php
namespace App\Core;

class Router {
    
    public function dispatch(string $uri, string $method) {
        // Strip query string
        $uri = explode('?', $uri)[0];
        $uri = rtrim($uri, '/');
        
        // Root redirect
        if ($uri === '' || $uri === '/') {
            header("Location: /dashboard");
            exit;
        }

        // Hardcoded basic routes mapping URI prefixes to Controllers for UI testing
        $routes = [
            '/dashboard' => ['controller' => 'Modules\Dashboard\Controllers\DashboardController', 'method' => 'index', 'module' => 'Dashboard'],
            '/crm/leads' => ['controller' => 'Modules\CRM\Controllers\LeadController', 'method' => 'index', 'module' => 'CRM'],
            '/projects' => ['controller' => 'Modules\Projects\Controllers\ProjectController', 'method' => 'index', 'module' => 'Projects'],
            '/accounting' => ['controller' => 'Modules\Accounting\Controllers\DashboardController', 'method' => 'index', 'module' => 'Accounting'],
            '/billing/invoices' => ['controller' => 'Modules\Billing\Controllers\InvoiceController', 'method' => 'index', 'module' => 'Billing'],
            '/hrm/employees' => ['controller' => 'Modules\HRM\Controllers\EmployeeController', 'method' => 'index', 'module' => 'HRM'],
            '/inventory' => ['controller' => 'Modules\Inventory\Controllers\ProductController', 'method' => 'index', 'module' => 'Inventory'],
            '/hosting/accounts' => ['controller' => 'Modules\Hosting\Controllers\AccountController', 'method' => 'index', 'module' => 'Hosting'],
            '/domains' => ['controller' => 'Modules\Domains\Controllers\DomainController', 'method' => 'index', 'module' => 'Domains'],
            '/reports' => ['controller' => 'Modules\Reports\Controllers\DashboardController', 'method' => 'index', 'module' => 'Reports'],
            '/security' => ['controller' => 'Modules\Security\Controllers\SecurityCenterController', 'method' => 'index', 'module' => 'Security'],
        ];

        // API routing fallback
        if (strpos($uri, '/api/') === 0) {
            $this->sendJsonError('API Routing not yet implemented in mock router.', 501);
            return;
        }

        // Check if route exists
        if (array_key_exists($uri, $routes)) {
            $target = $routes[$uri];
            $controllerClass = $target['controller'];
            $methodName = $target['method'];
            
            if (class_exists($controllerClass)) {
                $container = new \App\Core\Container();
                $controller = $container->resolve($controllerClass);
                if (method_exists($controller, $methodName)) {
                    // Execute the controller method
                    $controller->$methodName();
                    return;
                }
            }
        }

        // 404 Not Found Fallback
        http_response_code(404);
        require __DIR__ . '/../Views/layouts/master.php'; // Render inside master layout if possible
        echo "<h2>404 - Module or Route Not Found ($uri)</h2>";
    }

    private function sendJsonError($message, $code) {
        http_response_code($code);
        header('Content-Type: application/json');
        echo json_encode(['success' => false, 'message' => $message]);
        exit;
    }
}
