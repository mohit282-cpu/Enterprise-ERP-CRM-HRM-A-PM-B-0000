<?php
namespace Modules\Projects\Services;
use Modules\Projects\Repositories\ProjectRepository;

class ProjectService {
    private ProjectRepository $repo;
    public function __construct(ProjectRepository $repo) { $this->repo = $repo; }

    public function getProjectOverviews(): array {
        $projects = $this->repo->getAllProjects();
        foreach ($projects as &$p) {
            $p['progress_percentage'] = $p['total_tasks'] > 0 ? round(($p['completed_tasks'] / $p['total_tasks']) * 100) : 0;
        }
        return $projects;
    }
}
