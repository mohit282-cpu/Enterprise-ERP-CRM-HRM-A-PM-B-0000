<?php
use Modules\Dashboard\Controllers\ApiDashboardController;

return [
    'GET /api/dashboard/charts/revenue' => [ApiDashboardController::class, 'getChartData']
];
