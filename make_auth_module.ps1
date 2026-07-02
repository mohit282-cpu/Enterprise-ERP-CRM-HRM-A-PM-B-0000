$basePath = "z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"

$migrationPath = Join-Path $basePath "database\migrations\2026_01_01_000000_create_auth_tables.php"
$migrationContent = @'
<?php

class CreateAuthTables {
    public function up($db) {
        $sql = "
        CREATE TABLE branches (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            location VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE departments (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            branch_id INT,
            FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE SET NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE roles (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            slug VARCHAR(100) NOT NULL UNIQUE,
            description TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE permissions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            module VARCHAR(100) NOT NULL,
            action VARCHAR(100) NOT NULL,
            name VARCHAR(100) NOT NULL,
            slug VARCHAR(100) NOT NULL UNIQUE
        );

        CREATE TABLE users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            uuid CHAR(36) NOT NULL UNIQUE,
            first_name VARCHAR(100) NOT NULL,
            last_name VARCHAR(100) NOT NULL,
            email VARCHAR(255) NOT NULL UNIQUE,
            password VARCHAR(255) NOT NULL,
            phone VARCHAR(50),
            status ENUM('active', 'suspended', 'deactivated') DEFAULT 'active',
            2fa_enabled BOOLEAN DEFAULT FALSE,
            two_factor_secret VARCHAR(255),
            branch_id INT,
            department_id INT,
            role_id INT,
            last_login TIMESTAMP NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE SET NULL,
            FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
            FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE SET NULL
        );

        CREATE TABLE role_permissions (
            role_id INT,
            permission_id INT,
            PRIMARY KEY (role_id, permission_id),
            FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
            FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
        );

        CREATE TABLE audit_logs (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            table_name VARCHAR(100) NOT NULL,
            record_id INT NOT NULL,
            before_value JSON,
            after_value JSON,
            changed_by INT,
            reason TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE sessions (
            id VARCHAR(255) PRIMARY KEY,
            user_id INT,
            ip_address VARCHAR(45),
            user_agent TEXT,
            payload TEXT,
            last_activity INT,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
        ";
        $db->exec($sql);
    }

    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS sessions, audit_logs, role_permissions, users, permissions, roles, departments, branches;");
    }
}
'@
Set-Content -Path $migrationPath -Value $migrationContent -Encoding UTF8

$userModelPath = Join-Path $basePath "modules\Authentication\Models\User.php"
$userModelContent = @'
<?php

namespace Modules\Authentication\Models;

use App\Core\BaseModel;
use PDO;

class User extends BaseModel {
    protected string $table = 'users';

    public function findByEmail(string $email): ?array {
        $stmt = $this->db->prepare("SELECT * FROM {$this->table} WHERE email = :email LIMIT 1");
        $stmt->execute(['email' => $email]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    public function updateLastLogin(int $userId): void {
        $stmt = $this->db->prepare("UPDATE {$this->table} SET last_login = NOW() WHERE id = :id");
        $stmt->execute(['id' => $userId]);
    }
    
    public function hasPermission(int $userId, string $permissionSlug): bool {
        $stmt = $this->db->prepare("
            SELECT p.id FROM permissions p
            JOIN role_permissions rp ON p.id = rp.permission_id
            JOIN users u ON u.role_id = rp.role_id
            WHERE u.id = :user_id AND p.slug = :slug
        ");
        $stmt->execute(['user_id' => $userId, 'slug' => $permissionSlug]);
        return (bool)$stmt->fetch();
    }
}
'@
Set-Content -Path $userModelPath -Value $userModelContent -Encoding UTF8

$authServicePath = Join-Path $basePath "modules\Authentication\Services\AuthService.php"
$authServiceContent = @'
<?php

namespace Modules\Authentication\Services;

use Modules\Authentication\Models\User;
use Exception;

class AuthService {
    private User $userModel;

    public function __construct(User $userModel) {
        $this->userModel = $userModel;
    }

    public function login(string $email, string $password): array {
        $user = $this->userModel->findByEmail($email);
        
        if (!$user) {
            throw new Exception("Invalid credentials");
        }

        if ($user['status'] !== 'active') {
            throw new Exception("Account is not active");
        }

        if (!password_verify($password, $user['password'])) {
            // Track failed login logic here
            throw new Exception("Invalid credentials");
        }

        if ($user['2fa_enabled']) {
            return ['status' => '2fa_required', 'user_id' => $user['id']];
        }

        $this->startSession($user);
        return ['status' => 'success', 'user' => $user];
    }

    public function startSession(array $user): void {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
        
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['role_id'] = $user['role_id'];
        $_SESSION['last_activity'] = time();
        
        $this->userModel->updateLastLogin($user['id']);
    }

    public function logout(): void {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
        session_destroy();
    }
}
'@
Set-Content -Path $authServicePath -Value $authServiceContent -Encoding UTF8

$authControllerPath = Join-Path $basePath "modules\Authentication\Controllers\AuthController.php"
$authControllerContent = @'
<?php

namespace Modules\Authentication\Controllers;

use App\Core\BaseController;
use Modules\Authentication\Services\AuthService;
use Exception;

class AuthController extends BaseController {
    private AuthService $authService;

    public function __construct(AuthService $authService) {
        $this->authService = $authService;
    }

    public function login() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $email = $_POST['email'] ?? '';
            $password = $_POST['password'] ?? '';
            $csrfToken = $_POST['csrf_token'] ?? '';

            if (!$this->verifyCsrfToken($csrfToken)) {
                return $this->jsonResponse(['error' => 'Invalid CSRF token'], 403);
            }

            try {
                $result = $this->authService->login($email, $password);
                if ($result['status'] === 'success') {
                    return $this->redirect('/dashboard');
                } else if ($result['status'] === '2fa_required') {
                    return $this->redirect('/auth/2fa');
                }
            } catch (Exception $e) {
                return $this->view('auth/login', ['error' => $e->getMessage()]);
            }
        }
        
        return $this->view('auth/login');
    }

    public function logout() {
        $this->authService->logout();
        return $this->redirect('/login');
    }
}
'@
Set-Content -Path $authControllerPath -Value $authControllerContent -Encoding UTF8

$requireAuthPath = Join-Path $basePath "app\Http\Middleware\RequireAuth.php"
$requireAuthContent = @'
<?php

namespace App\Http\Middleware;

class RequireAuth {
    public function handle() {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }

        if (!isset($_SESSION['user_id'])) {
            header('Location: /login');
            exit;
        }

        // Check session timeout (e.g., 30 mins)
        if (isset($_SESSION['last_activity']) && (time() - $_SESSION['last_activity'] > 1800)) {
            session_unset();
            session_destroy();
            header('Location: /login?timeout=1');
            exit;
        }

        $_SESSION['last_activity'] = time();
    }
}
'@
Set-Content -Path $requireAuthPath -Value $requireAuthContent -Encoding UTF8

$checkPermissionPath = Join-Path $basePath "app\Http\Middleware\CheckPermission.php"
$checkPermissionContent = @'
<?php

namespace App\Http\Middleware;

use Modules\Authentication\Models\User;

class CheckPermission {
    public function handle(string $permissionSlug) {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }

        $userId = $_SESSION['user_id'] ?? null;
        if (!$userId) {
            header('Location: /login');
            exit;
        }

        $userModel = new User();
        if (!$userModel->hasPermission($userId, $permissionSlug)) {
            header('HTTP/1.0 403 Forbidden');
            echo "403 Forbidden - You do not have the required permission.";
            exit;
        }
    }
}
'@
Set-Content -Path $checkPermissionPath -Value $checkPermissionContent -Encoding UTF8

$readmePath = Join-Path $basePath "modules\Authentication\Docs\README.md"
$readmeContent = @'
# Authentication & User Management Module

This module serves as the foundational security layer for Sovryx OS, handling authentication, authorization (RBAC), and user administration.

## Features
- Login, Registration, Logout
- Role-Based Access Control (RBAC) via `CheckPermission` Middleware
- Organization Management (Branches, Departments, Teams)
- Session Management & Timeout
- Audit Logging & Security Tracking

## Architecture
- **Controllers**: Handle HTTP routing (`AuthController`, `UserController`)
- **Services**: Contain business logic (`AuthService`)
- **Models**: Database entities (`User`, `Role`, `Permission`)
- **Middleware**: Guard routes (`RequireAuth`, `CheckPermission`)

## Future Roadmap
- Implementation of TOTP (Google Authenticator) 2FA
- Integration of SSO (SAML/OAuth)
- Geo-location tracking for active sessions
'@
Set-Content -Path $readmePath -Value $readmeContent -Encoding UTF8

Write-Host "Authentication module core files generated successfully."
