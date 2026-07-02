<?php
namespace Modules\Projects\Controllers;
use App\Core\BaseController;
use Modules\Projects\Services\ProjectService;

class ProjectController extends BaseController {
    private ProjectService $service;
    public function __construct(ProjectService $service) { $this->service = $service; }

    public function index() {
        $projects = $this->service->getProjectOverviews();
        return $this->view('projects/index', ['projects' => $projects], 'Projects');
    }
}
