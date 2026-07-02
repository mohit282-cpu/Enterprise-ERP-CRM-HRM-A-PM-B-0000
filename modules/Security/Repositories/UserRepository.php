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
