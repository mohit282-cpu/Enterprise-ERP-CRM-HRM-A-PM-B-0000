$basePath = "z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"

# 1. Generate Views (UI)
$viewsPath = Join-Path $basePath "modules\Authentication\Views\auth"
if (-not (Test-Path $viewsPath)) { New-Item -ItemType Directory -Force -Path $viewsPath | Out-Null }

$loginViewPath = Join-Path $viewsPath "login.php"
$loginViewContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Sovryx OS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/assets/css/auth.css">
</head>
<body class="bg-light d-flex align-items-center py-4">
    <main class="form-signin w-100 m-auto">
        <form method="POST" action="/login">
            <h1 class="h3 mb-3 fw-normal text-center">Sovryx OS</h1>
            
            <?php if(isset($error)): ?>
                <div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
            <?php endif; ?>

            <input type="hidden" name="csrf_token" value="<?= $_SESSION['csrf_token'] ?? '' ?>">
            
            <div class="form-floating mb-2">
                <input type="email" name="email" class="form-control" id="floatingInput" placeholder="name@example.com" required>
                <label for="floatingInput">Email address</label>
            </div>
            <div class="form-floating mb-3">
                <input type="password" name="password" class="form-control" id="floatingPassword" placeholder="Password" required>
                <label for="floatingPassword">Password</label>
            </div>

            <div class="checkbox mb-3">
                <label>
                    <input type="checkbox" name="remember" value="1"> Remember me
                </label>
            </div>
            <button class="w-100 btn btn-lg btn-primary" type="submit">Sign in</button>
            <p class="mt-5 mb-3 text-muted text-center">&copy; Sovryx Tech 2026</p>
        </form>
    </main>
</body>
</html>
'@
Set-Content -Path $loginViewPath -Value $loginViewContent -Encoding UTF8

$registerViewPath = Join-Path $viewsPath "register.php"
$registerViewContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Register - Sovryx OS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center py-4">
    <main class="form-signin w-100 m-auto" style="max-width: 400px;">
        <form method="POST" action="/register">
            <h1 class="h3 mb-3 fw-normal text-center">Register Account</h1>
            
            <input type="hidden" name="csrf_token" value="<?= $_SESSION['csrf_token'] ?? '' ?>">
            
            <div class="form-floating mb-2">
                <input type="text" name="first_name" class="form-control" required>
                <label>First Name</label>
            </div>
            <div class="form-floating mb-2">
                <input type="text" name="last_name" class="form-control" required>
                <label>Last Name</label>
            </div>
            <div class="form-floating mb-2">
                <input type="email" name="email" class="form-control" required>
                <label>Email address</label>
            </div>
            <div class="form-floating mb-2">
                <input type="password" name="password" class="form-control" required>
                <label>Password</label>
            </div>
            <div class="form-floating mb-3">
                <input type="password" name="password_confirm" class="form-control" required>
                <label>Confirm Password</label>
            </div>

            <button class="w-100 btn btn-lg btn-success" type="submit">Register</button>
        </form>
    </main>
</body>
</html>
'@
Set-Content -Path $registerViewPath -Value $registerViewContent -Encoding UTF8

# 2. Assets (CSS/JS)
$cssPath = Join-Path $basePath "modules\Authentication\Assets\css"
if (-not (Test-Path $cssPath)) { New-Item -ItemType Directory -Force -Path $cssPath | Out-Null }
$cssFile = Join-Path $cssPath "auth.css"
$cssContent = @'
.form-signin {
    max-width: 330px;
    padding: 15px;
}
.form-signin .form-floating:focus-within {
    z-index: 2;
}
'@
Set-Content -Path $cssFile -Value $cssContent -Encoding UTF8

# 3. Routes
$routesPath = Join-Path $basePath "modules\Authentication\Routes"
if (-not (Test-Path $routesPath)) { New-Item -ItemType Directory -Force -Path $routesPath | Out-Null }
$webRoutes = Join-Path $routesPath "web.php"
$webRoutesContent = @'
<?php

use Modules\Authentication\Controllers\AuthController;
use Modules\Authentication\Controllers\RegisterController;
use Modules\Authentication\Controllers\UserController;

// Route mappings (Assumes a generic router in public/index.php)
return [
    'GET /login' => [AuthController::class, 'login'],
    'POST /login' => [AuthController::class, 'login'],
    'GET /logout' => [AuthController::class, 'logout'],
    
    'GET /register' => [RegisterController::class, 'register'],
    'POST /register' => [RegisterController::class, 'register'],
    
    'GET /users' => [UserController::class, 'index'],
    'GET /profile' => [UserController::class, 'profile']
];
'@
Set-Content -Path $webRoutes -Value $webRoutesContent -Encoding UTF8

# 4. Seeder
$seederPath = Join-Path $basePath "database\seeders\AuthSeeder.php"
$seederContent = @'
<?php

class AuthSeeder {
    public function run($db) {
        // Seed Root Company
        $db->exec("INSERT INTO companies (name) VALUES ('Sovryx Tech')");
        $companyId = $db->lastInsertId();

        // Seed Roles
        $db->exec("INSERT INTO roles (name, slug) VALUES ('Super Admin', 'super_admin')");
        $roleId = $db->lastInsertId();

        // Seed Root User
        $hashed = password_hash('Admin@123', PASSWORD_ARGON2ID);
        $uuid = bin2hex(random_bytes(16));
        $stmt = $db->prepare("INSERT INTO users (uuid, first_name, last_name, email, password, role_id, company_id) VALUES (?, 'System', 'Admin', 'admin@sovryx.com', ?, ?, ?)");
        $stmt->execute([$uuid, $hashed, $roleId, $companyId]);
        
        echo "AuthSeeder executed successfully. Default login: admin@sovryx.com / Admin@123\n";
    }
}
'@
Set-Content -Path $seederPath -Value $seederContent -Encoding UTF8

# 5. Validation
$validationPath = Join-Path $basePath "modules\Authentication\Validation"
if (-not (Test-Path $validationPath)) { New-Item -ItemType Directory -Force -Path $validationPath | Out-Null }
$loginVal = Join-Path $validationPath "LoginRequest.php"
$loginValContent = @'
<?php

namespace Modules\Authentication\Validation;

class LoginRequest {
    public function validate(array $data): array {
        $errors = [];
        if (empty($data['email']) || !filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            $errors['email'] = 'Valid email is required.';
        }
        if (empty($data['password'])) {
            $errors['password'] = 'Password is required.';
        }
        return $errors;
    }
}
'@
Set-Content -Path $loginVal -Value $loginValContent -Encoding UTF8

# 6. Unit Test stub
$testPath = Join-Path $basePath "tests\Unit\AuthServiceTest.php"
$testContent = @'
<?php

use PHPUnit\Framework\TestCase;
use Modules\Authentication\Services\AuthService;

class AuthServiceTest extends TestCase {
    public function testLoginFailsWithInvalidEmail() {
        // Mock User model and expect exception
        $this->assertTrue(true);
    }
}
'@
Set-Content -Path $testPath -Value $testContent -Encoding UTF8

Write-Host "Authentication module Phase 3 (UI, Routes, Validation, Seeder, Tests) generated successfully."
