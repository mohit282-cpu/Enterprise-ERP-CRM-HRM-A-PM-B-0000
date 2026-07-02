<?php
$pdo = new PDO('sqlite:database/database.sqlite');
$stmt = $pdo->query('SELECT email, password_hash FROM users');
print_r($stmt->fetchAll(PDO::FETCH_ASSOC));
