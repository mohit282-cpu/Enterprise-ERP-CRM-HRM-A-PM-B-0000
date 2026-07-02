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