$basePath = "Z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"

# 1. Master Layout Overhaul
$masterLayoutPath = Join-Path $basePath "app\Views\layouts\master.php"
$masterLayoutContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($activeModule ?? 'Sovryx OS') ?> - Enterprise ERP</title>
    <!-- Google Fonts: Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
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
        <nav id="sidebar" class="sidebar shadow-sm">
            <div class="sidebar-header d-flex align-items-center">
                <div class="logo-icon bg-primary text-white rounded me-2 d-flex justify-content-center align-items-center" style="width: 32px; height: 32px;">
                    <i class="fas fa-bolt"></i>
                </div>
                <h4 class="mb-0 fw-bold tracking-tight">Sovryx OS</h4>
            </div>
            
            <ul class="list-unstyled components mt-3">
                <li class="px-3 mb-2 text-uppercase text-muted fw-bold" style="font-size: 0.7rem; letter-spacing: 0.05em;">Modules</li>
                <?php
                    $modules = [
                        'Dashboard' => ['icon' => 'fa-home', 'url' => '/dashboard'],
                        'CRM' => ['icon' => 'fa-users', 'url' => '/crm/leads'],
                        'Projects' => ['icon' => 'fa-layer-group', 'url' => '/projects'],
                        'HRM' => ['icon' => 'fa-user-circle', 'url' => '/hrm/employees'],
                        'Accounting' => ['icon' => 'fa-wallet', 'url' => '/accounting'],
                        'Billing' => ['icon' => 'fa-file-invoice', 'url' => '/billing/invoices'],
                        'Inventory' => ['icon' => 'fa-box-open', 'url' => '/inventory'],
                        'Hosting' => ['icon' => 'fa-server', 'url' => '/hosting/accounts'],
                        'Domains' => ['icon' => 'fa-globe', 'url' => '/domains'],
                        'Reports' => ['icon' => 'fa-chart-bar', 'url' => '/reports'],
                        'Security' => ['icon' => 'fa-shield-halved', 'url' => '/security']
                    ];
                ?>
                <?php foreach($modules as $name => $m): ?>
                    <li class="<?= ($activeModule === $name) ? 'active' : '' ?> px-2 mb-1">
                        <a href="<?= $m['url'] ?>" class="rounded-3 d-flex align-items-center">
                            <i class="fas <?= $m['icon'] ?> fa-fw me-3 opacity-75"></i> <span class="fw-medium"><?= $name ?></span>
                        </a>
                    </li>
                <?php endforeach; ?>
            </ul>
        </nav>

        <!-- Page Content -->
        <div id="content" class="bg-light-surface w-100">
            
            <!-- Navbar -->
            <nav class="navbar navbar-expand-lg navbar-light glass-navbar sticky-top px-4 shadow-sm-soft">
                <div class="container-fluid p-0">
                    <button type="button" id="sidebarCollapse" class="btn btn-icon btn-light rounded-circle shadow-none border-0">
                        <i class="fas fa-bars"></i>
                    </button>
                    
                    <ul class="navbar-nav ms-auto align-items-center">
                        <li class="nav-item me-2">
                            <button class="btn btn-icon btn-light rounded-circle shadow-none border-0" id="darkModeToggle">
                                <i class="fas fa-moon text-muted"></i>
                            </button>
                        </li>
                        <li class="nav-item dropdown">
                            <a class="nav-link p-0 d-flex align-items-center" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown">
                                <img src="https://ui-avatars.com/api/?name=Admin+User&background=6366f1&color=fff&rounded=true" alt="User" class="rounded-circle" width="36" height="36">
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end border-0 shadow mt-2 rounded-3">
                                <li><a class="dropdown-item py-2" href="/profile"><i class="fas fa-user fa-sm fa-fw me-2 text-muted"></i> Profile</a></li>
                                <li><a class="dropdown-item py-2" href="/settings"><i class="fas fa-cog fa-sm fa-fw me-2 text-muted"></i> Settings</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item py-2 text-danger" href="/logout"><i class="fas fa-sign-out-alt fa-sm fa-fw me-2"></i> Logout</a></li>
                            </ul>
                        </li>
                    </ul>
                </div>
            </nav>

            <!-- Main Dynamic Content Container -->
            <main class="container-fluid px-4 py-4">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2 class="fw-bold tracking-tight mb-0 text-heading"><?= htmlspecialchars($activeModule ?? 'Dashboard') ?></h2>
                </div>

                <?php if (isset($success_message)): ?>
                    <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm" role="alert">
                        <i class="fas fa-check-circle me-2"></i> <?= htmlspecialchars($success_message) ?>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                <?php endif; ?>
                
                <?php if (isset($error_message)): ?>
                    <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm" role="alert">
                        <i class="fas fa-exclamation-triangle me-2"></i> <?= htmlspecialchars($error_message) ?>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                <?php endif; ?>

                <div class="module-content fade-in">
                    <?= $content ?? '' ?>
                </div>
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


# 2. Premium CSS Rewrite (Linear/Stripe aesthetic)
$cssPath = Join-Path $basePath "public\assets\css\app.css"
$cssContent = @'
:root {
    /* Linear/Stripe Inspired Variables */
    --primary-color: #6366f1;
    --primary-hover: #4f46e5;
    --bg-body: #f8fafc;
    --bg-surface: #ffffff;
    --sidebar-bg: #ffffff;
    --sidebar-border: #e2e8f0;
    --sidebar-text: #475569;
    --sidebar-text-hover: #0f172a;
    --sidebar-active-bg: #f1f5f9;
    
    --text-heading: #0f172a;
    --text-body: #334155;
    --text-muted: #64748b;
    
    --border-color: #e2e8f0;
    --shadow-soft: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
    --shadow-card: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
    --radius-md: 0.5rem;
    --radius-lg: 0.75rem;
}

[data-theme="dark"] {
    --primary-color: #818cf8;
    --primary-hover: #6366f1;
    --bg-body: #0f172a;
    --bg-surface: #1e293b;
    --sidebar-bg: #1e293b;
    --sidebar-border: #334155;
    --sidebar-text: #94a3b8;
    --sidebar-text-hover: #f8fafc;
    --sidebar-active-bg: #0f172a;
    
    --text-heading: #f8fafc;
    --text-body: #cbd5e1;
    --text-muted: #94a3b8;
    
    --border-color: #334155;
    --shadow-soft: 0 4px 6px -1px rgba(0, 0, 0, 0.2), 0 2px 4px -1px rgba(0, 0, 0, 0.1);
    --shadow-card: 0 4px 6px -1px rgba(0, 0, 0, 0.2);
}

body {
    background-color: var(--bg-body);
    color: var(--text-body);
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    transition: background-color 0.2s ease, color 0.2s ease;
    font-size: 0.9rem;
}

h1, h2, h3, h4, h5, h6, .text-heading {
    color: var(--text-heading);
}

.tracking-tight { letter-spacing: -0.025em; }

/* Wrapper and Sidebar */
.wrapper { display: flex; width: 100%; align-items: stretch; }

#sidebar {
    min-width: 260px;
    max-width: 260px;
    background: var(--sidebar-bg);
    border-right: 1px solid var(--sidebar-border);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    min-height: 100vh;
    z-index: 1040;
}

#sidebar.active { margin-left: -260px; }

#sidebar .sidebar-header {
    padding: 1.5rem 1.5rem;
}

#sidebar ul li a {
    padding: 0.6rem 1rem;
    font-size: 0.9rem;
    display: block;
    color: var(--sidebar-text);
    text-decoration: none;
    transition: all 0.2s;
}

#sidebar ul li a:hover {
    color: var(--sidebar-text-hover);
    background: var(--sidebar-active-bg);
}

#sidebar ul li.active > a {
    color: var(--primary-color);
    background: var(--sidebar-active-bg);
    font-weight: 600;
}

/* Navbar */
.glass-navbar {
    background: rgba(var(--bg-surface-rgb, 255, 255, 255), 0.8) !important;
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border-bottom: 1px solid var(--border-color);
    min-height: 64px;
}

[data-theme="dark"] .glass-navbar {
    background: rgba(30, 41, 59, 0.8) !important;
}

.btn-icon {
    width: 40px; height: 40px;
    display: flex; align-items: center; justify-content: center;
    background: transparent;
    color: var(--text-muted);
}
.btn-icon:hover {
    background: var(--sidebar-active-bg);
    color: var(--text-heading);
}

/* Cards (Overriding Bootstrap) */
.card {
    background-color: var(--bg-surface);
    border: 1px solid var(--border-color);
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-card);
    transition: box-shadow 0.2s ease;
}

.card:hover { box-shadow: var(--shadow-soft); }

.card-header {
    background-color: transparent;
    border-bottom: 1px solid var(--border-color);
    padding: 1rem 1.5rem;
    font-weight: 600;
}

.card-body { padding: 1.5rem; }

/* Tables */
.table {
    color: var(--text-body);
    margin-bottom: 0;
}
.table th {
    font-weight: 600;
    text-transform: uppercase;
    font-size: 0.75rem;
    letter-spacing: 0.05em;
    color: var(--text-muted);
    border-bottom: 1px solid var(--border-color);
    padding: 1rem;
    background-color: var(--bg-body);
}
.table td {
    padding: 1rem;
    vertical-align: middle;
    border-bottom: 1px solid var(--border-color);
}
.table tbody tr { transition: background-color 0.15s ease; }
.table tbody tr:hover { background-color: var(--sidebar-active-bg); }

/* Inputs & Buttons */
.form-control, .form-select {
    border-radius: var(--radius-md);
    border-color: var(--border-color);
    background-color: var(--bg-surface);
    color: var(--text-body);
    padding: 0.5rem 1rem;
}
.form-control:focus, .form-select:focus {
    border-color: var(--primary-color);
    box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2);
}

.btn-primary {
    background-color: var(--primary-color);
    border-color: var(--primary-color);
    border-radius: var(--radius-md);
    font-weight: 500;
    padding: 0.5rem 1.25rem;
    box-shadow: 0 1px 2px rgba(0,0,0,0.05);
}
.btn-primary:hover {
    background-color: var(--primary-hover);
    border-color: var(--primary-hover);
    transform: translateY(-1px);
}

.fade-in { animation: fadeIn 0.3s ease-in-out; }
@keyframes fadeIn { from { opacity: 0; transform: translateY(5px); } to { opacity: 1; transform: translateY(0); } }

[data-theme="dark"] .table { --bs-table-color: var(--text-body); --bs-table-bg: var(--bg-surface); }
[data-theme="dark"] .table th { background-color: var(--bg-body); }
'@
Set-Content -Path $cssPath -Value $cssContent -Encoding UTF8


# 3. HTML Stripping Script (Automated Hydration)
Write-Host "Starting Bulk HTML Stripping across all modules..."

$modulesPath = Join-Path $basePath "modules"
$viewFiles = Get-ChildItem -Path $modulesPath -Filter *.php -Recurse | Where-Object { $_.FullName -like "*\Views\*" }

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

foreach ($file in $viewFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    
    # Check if this file actually contains raw HTML tags we need to strip
    if ($content -match "<html" -or $content -match "<body") {
        
        # Regex patterns to strip
        # 1. Remove everything before and including <body>
        $content = $content -replace '(?si)^.*?(<body[^>]*>)\s*', ''
        
        # 2. Remove everything after and including </body>
        $content = $content -replace '(?si)\s*(</body>).*$', ''
        
        # 3. Strip raw <style> blocks (forcing them to use app.css)
        $content = $content -replace '(?si)<style>.*?</style>', ''
        
        # 4. Remove h1/h2 tags if they are just page titles (since master layout now handles titles dynamically)
        # We will wrap the remaining content in a clean card layout
        $cleanContent = @"
<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-body p-0">
                $content
            </div>
        </div>
    </div>
</div>
"@
        
        [System.IO.File]::WriteAllText($file.FullName, $cleanContent, $utf8NoBom)
        Write-Host "Stripped raw HTML from: $($file.Name)"
    }
}

Write-Host "UI Hydration Phase 2 completed successfully!"
