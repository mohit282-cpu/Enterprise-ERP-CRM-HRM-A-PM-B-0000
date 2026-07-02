<?php
namespace App\Core;

use PDO;
use PDOException;

class Database {
    private static $instance = null;
    
    public static function getInstance(): PDO {
        if (self::$instance === null) {
            try {
                $dbPath = __DIR__ . '/../../database/database.sqlite';
                self::$instance = new PDO("sqlite:" . $dbPath);
                self::$instance->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
                self::$instance->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
                
                // Enable foreign keys in SQLite
                self::$instance->exec('PRAGMA foreign_keys = ON;');
            } catch (PDOException $e) {
                die("Database Connection Failed: " . $e->getMessage());
            }
        }
        return self::$instance;
    }
}