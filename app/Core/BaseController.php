<?php
namespace App\Core;

class BaseController {
    
    /**
     * Render a view wrapped in the master layout.
     * 
     * @param string $viewPath e.g. 'dashboard/index'
     * @param array $data Data to extract into the view
     * @param string $activeModule Which sidebar link should be active
     */
    protected function view(string $viewPath, array $data = [], string $activeModule = 'Dashboard') {
        // Extract data to variables
        extract($data);
        
        // Output buffer the child view
        ob_start();
        $childViewFile = __DIR__ . '/../../modules/' . str_replace('/', '/Views/', $viewPath) . '.php';
        
        // Fallback for non-module core views if needed, but assuming modules for now
        // Let's infer module from caller namespace if needed, or pass full path
        // For simplicity in this architecture, we expect $viewPath like 'CRM/dashboard/index' 
        // Wait, our controllers did `$this->view('accounts/create', [], 'Hosting')`
        // So the module name is passed as $activeModule!
        
        $moduleDir = $activeModule; 
        $childViewFile = __DIR__ . "/../../modules/{$moduleDir}/Views/{$viewPath}.php";
        
        if (file_exists($childViewFile)) {
            require $childViewFile;
        } else {
            echo "<h2>View not found: {$childViewFile}</h2>";
        }
        $content = ob_get_clean();

        // Require the master layout, which will `echo $content` inside its <main> tag
        require __DIR__ . '/../Views/layouts/master.php';
        exit;
    }

    protected function jsonResponse($data, int $status = 200) {
        http_response_code($status);
        header('Content-Type: application/json');
        echo json_encode($data);
        exit;
    }

    protected function redirect(string $url) {
        header("Location: $url");
        exit;
    }
}
