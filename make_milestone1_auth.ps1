$basePath = "Z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# 1. Create Database Directory
$dbDir = Join-Path $basePath "database"
if (-not (Test-Path $dbDir)) { New-Item -Path $dbDir -ItemType Directory | Out-Null }

# 2. Update Database.php to use Real SQLite
$dbPhpPath = Join-Path $basePath "app\Core\Database.php"
$dbPhpContent = @'
<?php
namespace App\Core;

use PDO;
use PDOException;

class Database {
    private static $instance = null;
    
    public static function getInstance(): PDO {
        if (self::$instance === null) {
            try {
                $dbPath = __DIR__ . '/../../database/database.sqlite';
                self::$instance = new PDO("sqlite:" . $dbPath);
                self::$instance->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
                self::$instance->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
                
                // Enable foreign keys in SQLite
                self::$instance->exec('PRAGMA foreign_keys = ON;');
            } catch (PDOException $e) {
                die("Database Connection Failed: " . $e->getMessage());
            }
        }
        return self::$instance;
    }
}
'@
[System.IO.File]::WriteAllText($dbPhpPath, $dbPhpContent, $utf8NoBom)

# 3. Create Schema and Initialize DB
$schemaPath = Join-Path $dbDir "schema.sql"
$schemaContent = @'
-- Core SaaS Tables
CREATE TABLE IF NOT EXISTS tenants (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(255) NOT NULL,
    subdomain VARCHAR(100) UNIQUE NOT NULL,
    plan VARCHAR(50) DEFAULT 'free',
    status VARCHAR(20) DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tenant_id INTEGER NULL, -- NULL if Super Admin
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'user',
    two_factor_secret VARCHAR(255) NULL,
    status VARCHAR(20) DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    expires_at DATETIME NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Insert Demo Data
INSERT OR IGNORE INTO tenants (id, name, subdomain, plan) VALUES (1, 'Acme Corp', 'acme', 'pro');
INSERT OR IGNORE INTO tenants (id, name, subdomain, plan) VALUES (2, 'Stark Industries', 'stark', 'enterprise');

-- Password is 'password123' (bcrypt hash)
INSERT OR IGNORE INTO users (id, tenant_id, first_name, last_name, email, password_hash, role) 
VALUES (1, 1, 'John', 'Doe', 'john@acme.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin');

INSERT OR IGNORE INTO users (id, tenant_id, first_name, last_name, email, password_hash, role) 
VALUES (2, 2, 'Tony', 'Stark', 'tony@stark.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin');
'@
[System.IO.File]::WriteAllText($schemaPath, $schemaContent, $utf8NoBom)

# We can create the SQLite DB via PHP CLI
$initDbScript = Join-Path $basePath "init_db.php"
$initDbContent = @'
<?php
$dbPath = __DIR__ . "/database/database.sqlite";
$sql = file_get_contents(__DIR__ . "/database/schema.sql");
$pdo = new PDO("sqlite:" . $dbPath);
$pdo->exec($sql);
echo "SQLite Database Initialized successfully.\n";
'@
[System.IO.File]::WriteAllText($initDbScript, $initDbContent, $utf8NoBom)

# 4. Update TenantMiddleware to use DB
$middlewarePath = Join-Path $basePath "app\Core\TenantMiddleware.php"
$middlewareContent = @'
<?php
namespace App\Core;
use PDO;

class TenantMiddleware {
    public static function handle() {
        $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
        $parts = explode('.', $host);
        
        $subdomain = 'default';
        if (count($parts) > 1 && $host !== 'localhost:8000') {
            $subdomain = $parts[0];
        } else {
            // Local fallback
            $subdomain = 'acme';
        }
        
        $db = Database::getInstance();
        $stmt = $db->prepare("SELECT id, name FROM tenants WHERE subdomain = ? LIMIT 1");
        $stmt->execute([$subdomain]);
        $tenantData = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($tenantData) {
            TenantContext::getInstance()->setTenant($tenantData['id'], $tenantData['name'], $subdomain);
        } else {
            http_response_code(404);
            die("Tenant not found for subdomain: " . htmlspecialchars($subdomain));
        }
    }
}
'@
[System.IO.File]::WriteAllText($middlewarePath, $middlewareContent, $utf8NoBom)

# 5. Auth Controller, Service, Repository
$authCtrlPath = Join-Path $basePath "modules\Security\Controllers\AuthController.php"
$authCtrlContent = @'
<?php
namespace Modules\Security\Controllers;

use App\Core\BaseController;
use Modules\Security\Services\AuthService;

class AuthController extends BaseController {
    private AuthService $authService;
    
    public function __construct(AuthService $authService) {
        $this->authService = $authService;
    }
    
    public function loginView() {
        // If already logged in, redirect to dashboard
        if (isset($_SESSION['user_id'])) {
            $this->redirect('/dashboard');
        }
        
        // This view should bypass the master layout for a clean login page, 
        // but for now we'll inject it. Actually, login pages should be standalone.
        require __DIR__ . '/../Views/auth/login.php';
        exit;
    }
    
    public function login() {
        $email = $_POST['email'] ?? '';
        $password = $_POST['password'] ?? '';
        
        $user = $this->authService->attemptLogin($email, $password);
        
        if ($user) {
            // Regenerate session to prevent fixation
            session_regenerate_id(true);
            $_SESSION['user_id'] = $user['id'];
            $_SESSION['tenant_id'] = $user['tenant_id'];
            $_SESSION['first_name'] = $user['first_name'];
            $this->redirect('/dashboard');
        } else {
            $_SESSION['error'] = 'Invalid email or password.';
            $this->redirect('/login');
        }
    }
    
    public function logout() {
        session_destroy();
        $this->redirect('/login');
    }
}
'@
[System.IO.File]::WriteAllText($authCtrlPath, $authCtrlContent, $utf8NoBom)

$authSvcPath = Join-Path $basePath "modules\Security\Services\AuthService.php"
$authSvcContent = @'
<?php
namespace Modules\Security\Services;

use App\Core\BaseService;
use Modules\Security\Repositories\UserRepository;

class AuthService extends BaseService {
    private UserRepository $userRepo;
    
    public function __construct(UserRepository $userRepo) {
        $this->userRepo = $userRepo;
    }
    
    public function attemptLogin(string $email, string $password): ?array {
        $user = $this->userRepo->findByEmail($email);
        
        if ($user && password_verify($password, $user['password_hash'])) {
            return $user;
        }
        return null;
    }
}
'@
[System.IO.File]::WriteAllText($authSvcPath, $authSvcContent, $utf8NoBom)

$userRepoPath = Join-Path $basePath "modules\Security\Repositories\UserRepository.php"
$userRepoContent = @'
<?php
namespace Modules\Security\Repositories;

use App\Core\BaseRepository;
use App\Core\Database;
use PDO;

class UserRepository extends BaseRepository {
    
    public function findByEmail(string $email): ?array {
        $db = Database::getInstance();
        $stmt = $db->prepare("SELECT * FROM users WHERE email = ? LIMIT 1");
        $stmt->execute([$email]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        return $user ?: null;
    }
}
'@
[System.IO.File]::WriteAllText($userRepoPath, $userRepoContent, $utf8NoBom)

# 6. Login View (Standalone)
$authViewDir = Join-Path $basePath "modules\Security\Views\auth"
if (-not (Test-Path $authViewDir)) { New-Item -Path $authViewDir -ItemType Directory | Out-Null }
$loginViewPath = Join-Path $authViewDir "login.php"
$loginViewContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Sovryx OS</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="/assets/css/app.css">
    <style>
        body {
            background-color: var(--bg-body);
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .login-card {
            width: 100%;
            max-width: 400px;
            padding: 2rem;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-soft);
            background: var(--bg-surface);
            border: 1px solid var(--border-color);
        }
    </style>
</head>
<body>
    <div class="login-card">
        <div class="text-center mb-4">
            <div class="logo-icon bg-primary text-white rounded d-inline-flex justify-content-center align-items-center mb-3" style="width: 48px; height: 48px; font-size: 1.5rem;">
                <i class="fas fa-bolt"></i>
            </div>
            <h3 class="fw-bold tracking-tight text-heading">Sign in to Sovryx</h3>
            <p class="text-muted">Welcome back to <?= htmlspecialchars(\App\Core\TenantContext::getInstance()->getTenantName() ?? 'Workspace') ?></p>
        </div>
        
        <?php if (isset($_SESSION['error'])): ?>
            <div class="alert alert-danger py-2 px-3 text-sm border-0 rounded-3">
                <?= htmlspecialchars($_SESSION['error']); unset($_SESSION['error']); ?>
            </div>
        <?php endif; ?>

        <form action="/login" method="POST">
            <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($_SESSION['csrf_token'] ?? '') ?>">
            
            <div class="mb-3">
                <label class="form-label text-muted fw-semibold" style="font-size: 0.8rem;">Email Address</label>
                <input type="email" name="email" class="form-control form-control-lg fs-6" required placeholder="john@example.com" value="john@acme.com">
            </div>
            
            <div class="mb-4">
                <div class="d-flex justify-content-between">
                    <label class="form-label text-muted fw-semibold" style="font-size: 0.8rem;">Password</label>
                    <a href="#" class="text-primary text-decoration-none" style="font-size: 0.8rem;">Forgot password?</a>
                </div>
                <input type="password" name="password" class="form-control form-control-lg fs-6" required placeholder="••••••••" value="password123">
            </div>
            
            <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold">Sign In</button>
        </form>
    </div>
</body>
</html>
'@
[System.IO.File]::WriteAllText($loginViewPath, $loginViewContent, $utf8NoBom)

# 7. Update Router to map /login
$routerPath = Join-Path $basePath "app\Core\Router.php"
$routerContent = [System.IO.File]::ReadAllText($routerPath)
$newRoutes = @'
            '/login' => [
                'GET' => ['controller' => 'Modules\Security\Controllers\AuthController', 'method' => 'loginView', 'module' => 'Security'],
                'POST' => ['controller' => 'Modules\Security\Controllers\AuthController', 'method' => 'login', 'module' => 'Security']
            ],
            '/logout' => ['controller' => 'Modules\Security\Controllers\AuthController', 'method' => 'logout', 'module' => 'Security'],
'@
$routerContent = $routerContent -replace "'/dashboard' =>", "$newRoutes`n            '/dashboard' =>"

# Update router dispatch logic to support GET/POST routing
$routerContent = $routerContent -replace 'if \(array_key_exists\(\$uri, \$routes\)\) \{', 'if (array_key_exists($uri, $routes)) {
            $target = $routes[$uri];
            
            // Check if route is method-specific (e.g. GET/POST)
            if (isset($target[$method])) {
                $target = $target[$method];
            } elseif (isset($target["GET"]) || isset($target["POST"])) {
                $this->sendJsonError("Method Not Allowed", 405);
            }
'
[System.IO.File]::WriteAllText($routerPath, $routerContent, $utf8NoBom)

Write-Host "Milestone 1 Auth Core successfully scaffolded."
