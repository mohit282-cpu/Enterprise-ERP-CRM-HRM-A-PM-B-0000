<?php
use Modules\Dashboard\Controllers\DashboardController;

return [
    'GET /dashboard' => [DashboardController::class, 'index']
];
