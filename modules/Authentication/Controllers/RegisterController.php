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
