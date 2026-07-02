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
