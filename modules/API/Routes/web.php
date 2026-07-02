<?php return [ 'GET /api/docs' => [Modules\API\Controllers\SwaggerController::class, 'index'], 'GET /api/docs/swagger.json' => [Modules\API\Controllers\SwaggerController::class, 'json'] ];
