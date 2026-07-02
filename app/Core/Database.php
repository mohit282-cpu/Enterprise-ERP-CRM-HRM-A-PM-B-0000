<?php
namespace App\Core;

class Database {
    private static $instance = null;
    
    // For Phase 1 UI Testing, we return a mock PDO-like object
    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new MockPDO();
        }
        return self::$instance;
    }
}

class MockPDO {
    public function prepare($sql) {
        return new MockStatement();
    }
    public function query($sql) {
        return new MockStatement();
    }
    public function beginTransaction() {}
    public function commit() {}
    public function rollBack() {}
    public function lastInsertId() { return rand(1, 1000); }
}

class MockStatement {
    public function execute($params = []) { return true; }
    public function fetchAll($mode = null) { return []; }
    public function fetch($mode = null) { return null; }
}
