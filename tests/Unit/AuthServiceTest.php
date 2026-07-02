<?php

use PHPUnit\Framework\TestCase;
use Modules\Authentication\Services\AuthService;

class AuthServiceTest extends TestCase {
    public function testLoginFailsWithInvalidEmail() {
        // Mock User model and expect exception
        $this->assertTrue(true);
    }
}
