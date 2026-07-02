<?php
namespace Modules\API\Controllers;
use App\Core\BaseController;

class SwaggerController extends BaseController {
    public function index() {
        return $this->view('swagger/index', [], 'API');
    }

    public function json() {
        header('Content-Type: application/json');
        readfile(__DIR__ . '/../Docs/swagger.json');
        exit;
    }
}
