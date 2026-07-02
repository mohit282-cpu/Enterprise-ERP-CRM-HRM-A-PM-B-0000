<?php

namespace Modules\Authentication\Controllers;

use App\Core\BaseController;

class RoleController extends BaseController {
    public function index() {
        // List roles
        return $this->view('rbac/roles');
    }
}
