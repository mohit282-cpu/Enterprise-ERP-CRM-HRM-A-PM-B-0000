<?php
namespace Tests;

use PHPUnit\Framework\TestCase as BaseTestCase;
use App\Core\Database;

abstract class TestCase extends BaseTestCase {
    protected function setUp(): void {
        parent::setUp();
        // In a real environment, this would initialize the in-memory SQLite schema
        // $_ENV['APP_ENV'] = 'testing';
    }

    protected function tearDown(): void {
        // Clean up database transactions or state
        parent::tearDown();
    }
}
