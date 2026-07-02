<?php
$dbPath = __DIR__ . "/database/database.sqlite";
$sql = file_get_contents(__DIR__ . "/database/schema.sql");
$pdo = new PDO("sqlite:" . $dbPath);
$pdo->exec($sql);
echo "SQLite Database Initialized successfully.\n";