<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Sovryx OS</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="/assets/css/app.css">
    <style>
        body {
            background-color: var(--bg-body);
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .login-card {
            width: 100%;
            max-width: 400px;
            padding: 2rem;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-soft);
            background: var(--bg-surface);
            border: 1px solid var(--border-color);
        }
    </style>
</head>
<body>
    <div class="login-card">
        <div class="text-center mb-4">
            <div class="logo-icon bg-primary text-white rounded d-inline-flex justify-content-center align-items-center mb-3" style="width: 48px; height: 48px; font-size: 1.5rem;">
                <i class="fas fa-bolt"></i>
            </div>
            <h3 class="fw-bold tracking-tight text-heading">Sign in to Sovryx</h3>
            <p class="text-muted">Welcome back to <?= htmlspecialchars(\App\Core\TenantContext::getInstance()->getTenantName() ?? 'Workspace') ?></p>
        </div>
        
        <?php if (isset($_SESSION['error'])): ?>
            <div class="alert alert-danger py-2 px-3 text-sm border-0 rounded-3">
                <?= htmlspecialchars($_SESSION['error']); unset($_SESSION['error']); ?>
            </div>
        <?php endif; ?>

        <form action="/login" method="POST">
            <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($_SESSION['csrf_token'] ?? '') ?>">
            
            <div class="mb-3">
                <label class="form-label text-muted fw-semibold" style="font-size: 0.8rem;">Email Address</label>
                <input type="email" name="email" class="form-control form-control-lg fs-6" required placeholder="john@example.com" value="john@acme.com">
            </div>
            
            <div class="mb-4">
                <div class="d-flex justify-content-between">
                    <label class="form-label text-muted fw-semibold" style="font-size: 0.8rem;">Password</label>
                    <a href="#" class="text-primary text-decoration-none" style="font-size: 0.8rem;">Forgot password?</a>
                </div>
                <input type="password" name="password" class="form-control form-control-lg fs-6" required placeholder="â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢" value="password123">
            </div>
            
            <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold">Sign In</button>
        </form>
    </div>
</body>
</html>