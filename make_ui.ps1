$basePath = "z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"

# Directories
$dirs = @(
    "app\Core",
    "app\Views\layouts",
    "app\Views\components",
    "public\assets\css",
    "public\assets\js",
    "public\assets\images"
)

foreach ($dir in $dirs) {
    $fullPath = Join-Path $basePath $dir
    if (-not (Test-Path $fullPath)) { New-Item -ItemType Directory -Force -Path $fullPath | Out-Null }
}

# 1. Base Controller
$baseControllerPath = Join-Path $basePath "app\Core\BaseController.php"
$baseControllerContent = @'
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
'@
Set-Content -Path $baseControllerPath -Value $baseControllerContent -Encoding UTF8

# 2. Master Layout
$masterLayoutPath = Join-Path $basePath "app\Views\layouts\master.php"
$masterLayoutContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($activeModule ?? 'Sovryx OS') ?> - Enterprise ERP</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Custom CSS -->
    <link rel="stylesheet" href="/assets/css/app.css">
</head>
<body>
    
    <div class="wrapper">
        <!-- Sidebar -->
        <nav id="sidebar" class="sidebar">
            <div class="sidebar-header">
                <h3><i class="fas fa-cube me-2"></i>Sovryx OS</h3>
            </div>
            
            <ul class="list-unstyled components">
                <?php
                    $modules = [
                        'Dashboard' => ['icon' => 'fa-tachometer-alt', 'url' => '/dashboard'],
                        'CRM' => ['icon' => 'fa-users', 'url' => '/crm/leads'],
                        'Projects' => ['icon' => 'fa-project-diagram', 'url' => '/projects'],
                        'HRM' => ['icon' => 'fa-user-tie', 'url' => '/hrm/employees'],
                        'Accounting' => ['icon' => 'fa-file-invoice-dollar', 'url' => '/accounting'],
                        'Billing' => ['icon' => 'fa-receipt', 'url' => '/billing/invoices'],
                        'Inventory' => ['icon' => 'fa-boxes', 'url' => '/inventory'],
                        'Hosting' => ['icon' => 'fa-server', 'url' => '/hosting/accounts'],
                        'Domains' => ['icon' => 'fa-globe', 'url' => '/domains'],
                        'Reports' => ['icon' => 'fa-chart-pie', 'url' => '/reports'],
                        'Security' => ['icon' => 'fa-shield-alt', 'url' => '/security']
                    ];
                ?>
                <?php foreach($modules as $name => $m): ?>
                    <li class="<?= ($activeModule === $name) ? 'active' : '' ?>">
                        <a href="<?= $m['url'] ?>">
                            <i class="fas <?= $m['icon'] ?> fa-fw me-2"></i> <?= $name ?>
                        </a>
                    </li>
                <?php endforeach; ?>
            </ul>
        </nav>

        <!-- Page Content -->
        <div id="content">
            
            <!-- Navbar -->
            <nav class="navbar navbar-expand-lg navbar-light bg-light shadow-sm topbar mb-4 static-top">
                <div class="container-fluid">
                    <button type="button" id="sidebarCollapse" class="btn btn-primary">
                        <i class="fas fa-bars"></i>
                    </button>
                    
                    <ul class="navbar-nav ms-auto">
                        <li class="nav-item">
                            <button class="btn btn-outline-secondary me-3" id="darkModeToggle">
                                <i class="fas fa-moon"></i>
                            </button>
                        </li>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown">
                                <i class="fas fa-user-circle fa-fw"></i> Admin
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><a class="dropdown-item" href="/profile"><i class="fas fa-user fa-sm fa-fw me-2 text-gray-400"></i> Profile</a></li>
                                <li><a class="dropdown-item" href="/settings"><i class="fas fa-cogs fa-sm fa-fw me-2 text-gray-400"></i> Settings</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="/logout"><i class="fas fa-sign-out-alt fa-sm fa-fw me-2 text-gray-400"></i> Logout</a></li>
                            </ul>
                        </li>
                    </ul>
                </div>
            </nav>

            <!-- Main Dynamic Content Container -->
            <main class="container-fluid px-4">
                <?php if (isset($success_message)): ?>
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <?= htmlspecialchars($success_message) ?>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                <?php endif; ?>
                
                <?php if (isset($error_message)): ?>
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <?= htmlspecialchars($error_message) ?>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                <?php endif; ?>

                <?= $content ?? '' ?>
            </main>

        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Custom JS -->
    <script src="/assets/js/app.js"></script>
</body>
</html>
'@
Set-Content -Path $masterLayoutPath -Value $masterLayoutContent -Encoding UTF8

# 3. Custom CSS
$cssPath = Join-Path $basePath "public\assets\css\app.css"
$cssContent = @'
:root {
    --primary-color: #4e73df;
    --sidebar-bg: #2a2a2a;
    --sidebar-text: #fff;
    --bg-color: #f8f9fc;
    --text-color: #5a5c69;
    --card-bg: #fff;
    --border-color: #e3e6f0;
}

[data-theme="dark"] {
    --primary-color: #375a7f;
    --sidebar-bg: #1a1a1a;
    --bg-color: #121212;
    --text-color: #e0e0e0;
    --card-bg: #1e1e1e;
    --border-color: #333;
}

body {
    background-color: var(--bg-color);
    color: var(--text-color);
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    transition: background-color 0.3s ease, color 0.3s ease;
}

/* Wrapper and Sidebar */
.wrapper {
    display: flex;
    width: 100%;
    align-items: stretch;
}

#sidebar {
    min-width: 250px;
    max-width: 250px;
    background: var(--sidebar-bg);
    color: var(--sidebar-text);
    transition: all 0.3s;
    min-height: 100vh;
}

#sidebar.active {
    margin-left: -250px;
}

#sidebar .sidebar-header {
    padding: 20px;
    background: rgba(0,0,0,0.1);
}

#sidebar ul.components {
    padding: 20px 0;
}

#sidebar ul li a {
    padding: 15px 20px;
    font-size: 1.1em;
    display: block;
    color: rgba(255,255,255,0.7);
    text-decoration: none;
    transition: 0.2s;
}

#sidebar ul li a:hover, #sidebar ul li.active > a {
    color: #fff;
    background: rgba(255,255,255,0.1);
    border-left: 4px solid var(--primary-color);
}

/* Content Area */
#content {
    width: 100%;
    padding: 0;
    min-height: 100vh;
    transition: all 0.3s;
}

.topbar {
    background: var(--card-bg) !important;
    border-bottom: 1px solid var(--border-color);
}

/* Cards */
.card {
    background-color: var(--card-bg);
    border: 1px solid var(--border-color);
    border-radius: 0.5rem;
    box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
}

/* Tables */
.table {
    color: var(--text-color);
}
[data-theme="dark"] .table {
    --bs-table-color: var(--text-color);
    --bs-table-bg: var(--card-bg);
    --bs-table-border-color: var(--border-color);
}
'@
Set-Content -Path $cssPath -Value $cssContent -Encoding UTF8

# 4. Custom JS
$jsPath = Join-Path $basePath "public\assets\js\app.js"
$jsContent = @'
document.addEventListener("DOMContentLoaded", function() {
    
    // Sidebar Toggle
    const sidebarCollapse = document.getElementById('sidebarCollapse');
    const sidebar = document.getElementById('sidebar');
    
    if (sidebarCollapse && sidebar) {
        sidebarCollapse.addEventListener('click', function() {
            sidebar.classList.toggle('active');
        });
    }

    // Dark Mode Toggle
    const darkModeToggle = document.getElementById('darkModeToggle');
    const currentTheme = localStorage.getItem('theme') || 'light';
    
    if (currentTheme === 'dark') {
        document.documentElement.setAttribute('data-theme', 'dark');
        if(darkModeToggle) darkModeToggle.innerHTML = '<i class="fas fa-sun"></i>';
    }

    if (darkModeToggle) {
        darkModeToggle.addEventListener('click', function() {
            let theme = document.documentElement.getAttribute('data-theme');
            
            if (theme === 'dark') {
                document.documentElement.setAttribute('data-theme', 'light');
                localStorage.setItem('theme', 'light');
                this.innerHTML = '<i class="fas fa-moon"></i>';
            } else {
                document.documentElement.setAttribute('data-theme', 'dark');
                localStorage.setItem('theme', 'dark');
                this.innerHTML = '<i class="fas fa-sun"></i>';
            }
        });
    }

    // Initialize Tooltips
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl)
    });
});
'@
Set-Content -Path $jsPath -Value $jsContent -Encoding UTF8

Write-Host "Enterprise UI Engine Phase 1 built successfully."
