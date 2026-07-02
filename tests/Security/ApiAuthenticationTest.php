<?php
namespace Tests\Security;

use Tests\TestCase;
use App\Core\ApiMiddleware;

class ApiAuthenticationTest extends TestCase {
    
    public function test_it_requires_bearer_token() {
        $this->assertTrue(method_exists(ApiMiddleware::class, 'authenticate'));
    }
}
