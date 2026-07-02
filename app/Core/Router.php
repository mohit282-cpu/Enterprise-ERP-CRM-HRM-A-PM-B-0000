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
            '/projects' => [
                'GET' => ['controller' => 'Modules\Projects\Controllers\ProjectController', 'method' => 'index', 'module' => 'Projects'],
                'POST' => ['controller' => 'Modules\Projects\Controllers\ProjectController', 'method' => 'store', 'module' => 'Projects']
            ],
            '/accounting' => [
                'GET' => ['controller' => 'Modules\Accounting\Controllers\DashboardController', 'method' => 'index', 'module' => 'Accounting'],
                'POST' => ['controller' => 'Modules\Accounting\Controllers\DashboardController', 'method' => 'store', 'module' => 'Accounting']
            ],
            '/billing/invoices' => [
                'GET' => ['controller' => 'Modules\Billing\Controllers\InvoiceController', 'method' => 'index', 'module' => 'Billing'],
                'POST' => ['controller' => 'Modules\Billing\Controllers\InvoiceController', 'method' => 'store', 'module' => 'Billing']
            ],
            '/hrm/employees' => [
                'GET' => ['controller' => 'Modules\HRM\Controllers\EmployeeController', 'method' => 'index', 'module' => 'HRM'],
                'POST' => ['controller' => 'Modules\HRM\Controllers\EmployeeController', 'method' => 'store', 'module' => 'HRM']
            ],
            '/inventory' => [
                'GET' => ['controller' => 'Modules\Inventory\Controllers\ProductController', 'method' => 'index', 'module' => 'Inventory'],
                'POST' => ['controller' => 'Modules\Inventory\Controllers\ProductController', 'method' => 'store', 'module' => 'Inventory']
            ],
            '/hosting/accounts' => [
                'GET' => ['controller' => 'Modules\Hosting\Controllers\AccountController', 'method' => 'index', 'module' => 'Hosting'],
                'POST' => ['controller' => 'Modules\Hosting\Controllers\AccountController', 'method' => 'store', 'module' => 'Hosting']
            ],
            '/domains' => [
                'GET' => ['controller' => 'Modules\Domains\Controllers\DomainController', 'method' => 'index', 'module' => 'Domains'],
                'POST' => ['controller' => 'Modules\Domains\Controllers\DomainController', 'method' => 'store', 'module' => 'Domains']
            ],
            '/reports' => [
                'GET' => ['controller' => 'Modules\Reports\Controllers\ReportsController', 'method' => 'index', 'module' => 'Reports']
            ],
            '/security' => [
                'GET' => ['controller' => 'Modules\Security\Controllers\SecurityCenterController', 'method' => 'index', 'module' => 'Security']
            ],
        ];

        // API routing fallback
        if (strpos($uri, '/api/') === 0) {
            $this->sendJsonError('API Routing not yet implemented in mock router.', 501);
            return;
        }

        // Check if route exists
        if (array_key_exists($uri, $routes)) {
            $target = $routes[$uri];
            
            // Check if route is method-specific (e.g. GET/POST)
            if (isset($target[$method])) {
                $target = $target[$method];
            } elseif (isset($target["GET"]) || isset($target["POST"])) {
                $this->sendJsonError("Method Not Allowed", 405);
            }
            
            $controllerClass = $target['controller'];
            $methodName = $target['method'];
            
            // Basic Auth Middleware
            if ($uri !== '/login' && !isset($_SESSION['user_id'])) {
                header("Location: /login");
                exit;
            }
            
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
        $content = "<div class='text-center py-5'><h2 class='text-danger fw-bold'>404 - Module or Route Not Found</h2><p class='text-muted'>$uri could not be resolved by the router.</p></div>";
        require __DIR__ . '/../Views/layouts/master.php';
    }

    private function sendJsonError($message, $code) {
        http_response_code($code);
        header('Content-Type: application/json');
        echo json_encode(['success' => false, 'message' => $message]);
        exit;
    }
}
