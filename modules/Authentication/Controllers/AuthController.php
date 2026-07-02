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
