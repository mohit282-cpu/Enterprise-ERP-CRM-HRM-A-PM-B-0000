<?php
namespace App\Core;

abstract class ApiController {
    
    /**
     * Send standard JSON success response
     */
    protected function sendSuccess($data = null, string $message = 'Success', int $statusCode = 200) {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        echo json_encode([
            'success' => true,
            'message' => $message,
            'data' => $data
        ]);
        exit;
    }

    /**
     * Send standard JSON error response
     */
    protected function sendError(string $message, int $statusCode = 400, $errors = null) {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        echo json_encode([
            'success' => false,
            'message' => $message,
            'errors' => $errors
        ]);
        exit;
    }
}
