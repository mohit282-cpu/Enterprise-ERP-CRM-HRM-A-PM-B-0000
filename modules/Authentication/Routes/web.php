<?php

use Modules\Authentication\Controllers\AuthController;
use Modules\Authentication\Controllers\RegisterController;
use Modules\Authentication\Controllers\UserController;

// Route mappings (Assumes a generic router in public/index.php)
return [
    'GET /login' => [AuthController::class, 'login'],
    'POST /login' => [AuthController::class, 'login'],
    'GET /logout' => [AuthController::class, 'logout'],
    
    'GET /register' => [RegisterController::class, 'register'],
    'POST /register' => [RegisterController::class, 'register'],
    
    'GET /users' => [UserController::class, 'index'],
    'GET /profile' => [UserController::class, 'profile']
];
