<?php
$hash = password_hash('password123', PASSWORD_BCRYPT);
$pdo = new PDO('sqlite:database/database.sqlite');
$pdo->exec("UPDATE users SET password_hash = '$hash'");
echo "Passwords updated to password123\n";
