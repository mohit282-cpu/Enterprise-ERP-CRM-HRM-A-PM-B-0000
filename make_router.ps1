$basePath = "z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"

# 1. Front Controller (public/index.php)
$indexPhpPath = Join-Path $basePath "public\index.php"
$indexPhpContent = @'
<?php
/**
 * Sovryx OS - Enterprise Front Controller
 */

// 1. Error Reporting (Dev Mode)
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// 2. Start Secure Session
session_name('SOVRYX_SESSION');
session_set_cookie_params([
    'lifetime' => 0,
    'path' => '/',
    'domain' => '',
    'secure' => false, // Set true in production with HTTPS
    'httponly' => true,
    'samesite' => 'Strict'
]);
session_start();

// Generate CSRF token if missing
if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}

// 3. PSR-4 Autoloader
spl_autoload_register(function ($class) {
    // Project-specific namespace prefix mappings
    $prefixes = [
        'App\\' => __DIR__ . '/../app/',
        'Modules\\' => __DIR__ . '/../modules/'
    ];

    foreach ($prefixes as $prefix => $base_dir) {
        // Does the class use the namespace prefix?
        $len = strlen($prefix);
        if (strncmp($prefix, $class, $len) !== 0) {
            continue;
        }

        // Get the relative class name
        $relative_class = substr($class, $len);

        // Replace namespace separators with directory separators, append .php
        $file = $base_dir . str_replace('\\', '/', $relative_class) . '.php';

        // Require the file if it exists
        if (file_exists($file)) {
            require $file;
            return;
        }
    }
});

// 4. Initialize Core Singletons & Run Router
try {
    // Invoke Global Security Middleware (X-Frame-Options, CSRF checks)
    \App\Core\SecurityMiddleware::handle();

    // Parse URI and Dispatch
    $router = new \App\Core\Router();
    $router->dispatch($_SERVER['REQUEST_URI'], $_SERVER['REQUEST_METHOD']);

} catch (Exception $e) {
    // Global Exception Handler
    http_response_code(500);
    echo "<h1>500 Internal Server Error</h1>";
    echo "<p>" . htmlspecialchars($e->getMessage()) . "</p>";
}
'@
Set-Content -Path $indexPhpPath -Value $indexPhpContent -Encoding UTF8

# 2. Router Engine (app/Core/Router.php)
$routerPath = Join-Path $basePath "app\Core\Router.php"
$routerContent = @'
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
                $controller = new $controllerClass();
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
'@
Set-Content -Path $routerPath -Value $routerContent -Encoding UTF8

# 3. Mock Database (app/Core/Database.php)
$dbPath = Join-Path $basePath "app\Core\Database.php"
$dbContent = @'
<?php
namespace App\Core;

class Database {
    private static $instance = null;
    
    // For Phase 1 UI Testing, we return a mock PDO-like object
    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new MockPDO();
        }
        return self::$instance;
    }
}

class MockPDO {
    public function prepare($sql) {
        return new MockStatement();
    }
    public function beginTransaction() {}
    public function commit() {}
    public function rollBack() {}
    public function lastInsertId() { return rand(1, 1000); }
}

class MockStatement {
    public function execute($params = []) { return true; }
    public function fetchAll($mode = null) { return []; }
    public function fetch($mode = null) { return null; }
}
'@
Set-Content -Path $dbPath -Value $dbContent -Encoding UTF8

Write-Host "Application Bootstrapper generated successfully."
