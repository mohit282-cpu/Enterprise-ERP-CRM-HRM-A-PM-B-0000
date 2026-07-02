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
