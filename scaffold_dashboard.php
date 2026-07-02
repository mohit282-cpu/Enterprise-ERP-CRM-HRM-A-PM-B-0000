<?php
$basePath = __DIR__;

$moduleName = 'Dashboard';
$moduleDir = $basePath . '/modules/' . $moduleName;

@mkdir($moduleDir . '/Controllers', 0777, true);

$controllerCode = "<?php
namespace Modules\Dashboard\Controllers;

use App\Core\BaseController;

class DashboardController extends BaseController {
    public function __construct() {
        // Dashboard doesn't need a specific service yet
    }
    
    public function index() {
        \$metrics = [
            ['id' => 1, 'name' => 'Total Revenue', 'value' => '$150,000'],
            ['id' => 2, 'name' => 'Active Projects', 'value' => '12'],
            ['id' => 3, 'name' => 'New Leads', 'value' => '45']
        ];
        return \$this->view('index', ['metrics' => \$metrics], 'Dashboard');
    }
}
";
file_put_contents($moduleDir . '/Controllers/DashboardController.php', $controllerCode);
echo "Scaffolded Dashboard logic.\n";
