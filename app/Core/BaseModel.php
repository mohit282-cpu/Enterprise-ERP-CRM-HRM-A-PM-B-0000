<?php
namespace App\Core;

abstract class BaseModel {
    protected string $table;
    protected $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function getTable(): string {
        return $this->table;
    }
    
    public function getDb() {
        return $this->db;
    }
}
