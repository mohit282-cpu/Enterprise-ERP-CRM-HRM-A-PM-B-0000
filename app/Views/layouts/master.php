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
