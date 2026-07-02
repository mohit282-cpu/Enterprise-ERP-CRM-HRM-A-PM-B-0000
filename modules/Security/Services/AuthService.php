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