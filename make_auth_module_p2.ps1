$basePath = "z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"

$registerControllerPath = Join-Path $basePath "modules\Authentication\Controllers\RegisterController.php"
$registerControllerContent = @'
<?php

namespace Modules\Authentication\Controllers;

use App\Core\BaseController;
use Modules\Authentication\Services\RegisterService;
use Exception;

class RegisterController extends BaseController {
    private RegisterService $registerService;

    public function __construct(RegisterService $registerService) {
        $this->registerService = $registerService;
    }

    public function register() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $data = [
                'first_name' => $_POST['first_name'] ?? '',
                'last_name' => $_POST['last_name'] ?? '',
                'email' => $_POST['email'] ?? '',
                'password' => $_POST['password'] ?? '',
                'password_confirm' => $_POST['password_confirm'] ?? ''
            ];
            
            $csrfToken = $_POST['csrf_token'] ?? '';

            if (!$this->verifyCsrfToken($csrfToken)) {
                return $this->jsonResponse(['error' => 'Invalid CSRF token'], 403);
            }

            try {
                $this->registerService->registerUser($data);
                return $this->redirect('/login?registered=1');
            } catch (Exception $e) {
                return $this->view('auth/register', ['error' => $e->getMessage(), 'old' => $data]);
            }
        }
        
        return $this->view('auth/register');
    }
}
'@
Set-Content -Path $registerControllerPath -Value $registerControllerContent -Encoding UTF8

$registerServicePath = Join-Path $basePath "modules\Authentication\Services\RegisterService.php"
$registerServiceContent = @'
<?php

namespace Modules\Authentication\Services;

use Modules\Authentication\Models\User;
use Exception;
use PDO;

class RegisterService {
    private User $userModel;

    public function __construct(User $userModel) {
        $this->userModel = $userModel;
    }

    public function registerUser(array $data): void {
        if (empty($data['first_name']) || empty($data['last_name']) || empty($data['email']) || empty($data['password'])) {
            throw new Exception("All fields are required.");
        }

        if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            throw new Exception("Invalid email format.");
        }

        if (strlen($data['password']) < 8) {
            throw new Exception("Password must be at least 8 characters long.");
        }

        if ($data['password'] !== $data['password_confirm']) {
            throw new Exception("Passwords do not match.");
        }

        $existing = $this->userModel->findByEmail($data['email']);
        if ($existing) {
            throw new Exception("Email already exists.");
        }

        $hashedPassword = password_hash($data['password'], PASSWORD_ARGON2ID);
        $uuid = bin2hex(random_bytes(16)); // Basic UUID representation

        $stmt = $this->userModel->getDb()->prepare("
            INSERT INTO users (uuid, first_name, last_name, email, password, status)
            VALUES (:uuid, :first_name, :last_name, :email, :password, 'active')
        ");
        
        $stmt->execute([
            'uuid' => $uuid,
            'first_name' => $data['first_name'],
            'last_name' => $data['last_name'],
            'email' => $data['email'],
            'password' => $hashedPassword
        ]);
        
        // Dispatch UserCreatedEvent here in real app
    }
}
'@
Set-Content -Path $registerServicePath -Value $registerServiceContent -Encoding UTF8

$userControllerPath = Join-Path $basePath "modules\Authentication\Controllers\UserController.php"
$userControllerContent = @'
<?php

namespace Modules\Authentication\Controllers;

use App\Core\BaseController;
use Modules\Authentication\Services\UserService;
use Exception;

class UserController extends BaseController {
    private UserService $userService;

    public function __construct(UserService $userService) {
        $this->userService = $userService;
    }

    public function index() {
        $users = $this->userService->getAllUsers();
        return $this->view('users/index', ['users' => $users]);
    }
    
    public function profile() {
        $userId = $_SESSION['user_id'];
        $user = $this->userService->getUserById($userId);
        return $this->view('users/profile', ['user' => $user]);
    }
}
'@
Set-Content -Path $userControllerPath -Value $userControllerContent -Encoding UTF8

$userServicePath = Join-Path $basePath "modules\Authentication\Services\UserService.php"
$userServiceContent = @'
<?php

namespace Modules\Authentication\Services;

use Modules\Authentication\Models\User;
use PDO;

class UserService {
    private User $userModel;

    public function __construct(User $userModel) {
        $this->userModel = $userModel;
    }

    public function getAllUsers(): array {
        $stmt = $this->userModel->getDb()->query("SELECT id, first_name, last_name, email, status, created_at FROM users");
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    public function getUserById(int $id): ?array {
        $stmt = $this->userModel->getDb()->prepare("SELECT id, first_name, last_name, email, phone, status, 2fa_enabled FROM users WHERE id = :id");
        $stmt->execute(['id' => $id]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }
    
    public function updateUser(int $id, array $data): bool {
        // Implementation for updating a user
        return true;
    }
    
    public function deleteUser(int $id): bool {
        // Implementation for soft deleting a user
        return true;
    }
}
'@
Set-Content -Path $userServicePath -Value $userServiceContent -Encoding UTF8

$roleControllerPath = Join-Path $basePath "modules\Authentication\Controllers\RoleController.php"
$roleControllerContent = @'
<?php

namespace Modules\Authentication\Controllers;

use App\Core\BaseController;

class RoleController extends BaseController {
    public function index() {
        // List roles
        return $this->view('rbac/roles');
    }
}
'@
Set-Content -Path $roleControllerPath -Value $roleControllerContent -Encoding UTF8

Write-Host "Authentication module Phase 2 backend files generated successfully."
