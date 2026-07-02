<?php
namespace Modules\Projects\Controllers;

use App\Core\BaseController;
use Modules\Projects\Services\ProjectService;

class ProjectController extends BaseController {
    private ProjectService $service;
    
    public function __construct(ProjectService $service) {
        $this->service = $service;
    }
    
    public function index() {
        $data = $this->service->getAllRecords();
        return $this->view('projects/index', ['projects' => $data], 'Projects');
    }

    public function store() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $data = $_POST;
            $this->service->createRecord($data);
            header('Location: /projects');
            exit;
        }
    }
}
