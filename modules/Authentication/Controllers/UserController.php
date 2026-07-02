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
