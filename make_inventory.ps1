$basePath = "z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"

# Directories
$dirs = @(
    "database\migrations",
    "modules\Inventory\Models",
    "modules\Inventory\Repositories",
    "modules\Inventory\Services",
    "modules\Inventory\Controllers",
    "modules\Inventory\Routes",
    "modules\Inventory\Views\products",
    "modules\Inventory\Views\stock"
)

foreach ($dir in $dirs) {
    $fullPath = Join-Path $basePath $dir
    if (-not (Test-Path $fullPath)) { New-Item -ItemType Directory -Force -Path $fullPath | Out-Null }
}

# 1. Database Migration
$migrationPath = Join-Path $basePath "database\migrations\2026_01_11_000000_create_inventory_tables.php"
$migrationContent = @'
<?php
class CreateInventoryTables {
    public function up($db) {
        $sql = "
        -- Drop basic operational tables if they exist to replace with Enterprise logic
        DROP TABLE IF EXISTS inventory_transactions, products, product_categories;

        CREATE TABLE warehouses (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            location VARCHAR(255),
            is_active BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE suppliers (
            id INT AUTO_INCREMENT PRIMARY KEY,
            company_name VARCHAR(150) NOT NULL,
            contact_name VARCHAR(100),
            email VARCHAR(100),
            phone VARCHAR(50),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE product_categories (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            parent_id INT NULL,
            FOREIGN KEY (parent_id) REFERENCES product_categories(id) ON DELETE SET NULL
        );

        CREATE TABLE products (
            id INT AUTO_INCREMENT PRIMARY KEY,
            category_id INT NULL,
            supplier_id INT NULL,
            name VARCHAR(255) NOT NULL,
            sku VARCHAR(100) NOT NULL UNIQUE,
            barcode VARCHAR(100) UNIQUE,
            qr_code VARCHAR(255),
            cost_price DECIMAL(15,4) NOT NULL DEFAULT 0.0000,
            selling_price DECIMAL(15,4) NOT NULL DEFAULT 0.0000,
            is_active BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (category_id) REFERENCES product_categories(id) ON DELETE SET NULL,
            FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL
        );

        CREATE TABLE inventory_stock (
            id INT AUTO_INCREMENT PRIMARY KEY,
            product_id INT NOT NULL,
            warehouse_id INT NOT NULL,
            quantity DECIMAL(15,4) NOT NULL DEFAULT 0.0000,
            last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
            FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON DELETE CASCADE,
            UNIQUE KEY product_warehouse (product_id, warehouse_id)
        );

        CREATE TABLE stock_movements (
            id INT AUTO_INCREMENT PRIMARY KEY,
            product_id INT NOT NULL,
            warehouse_id INT NOT NULL,
            user_id INT NOT NULL,
            type ENUM('in', 'out', 'transfer') NOT NULL,
            quantity DECIMAL(15,4) NOT NULL,
            reference_type VARCHAR(50), -- e.g., 'purchase_order', 'manual_adjustment'
            reference_id INT,
            notes TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT,
            FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON DELETE RESTRICT,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
        );
        ";
        $db->exec($sql);
    }
    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS stock_movements, inventory_stock, products, product_categories, suppliers, warehouses;");
    }
}
'@
Set-Content -Path $migrationPath -Value $migrationContent -Encoding UTF8

# 2. Models
$productModelPath = Join-Path $basePath "modules\Inventory\Models\Product.php"
Set-Content -Path $productModelPath -Value "<?php namespace Modules\Inventory\Models; use App\Core\BaseModel; class Product extends BaseModel { protected string `$table = 'products'; }" -Encoding UTF8

$warehouseModelPath = Join-Path $basePath "modules\Inventory\Models\Warehouse.php"
Set-Content -Path $warehouseModelPath -Value "<?php namespace Modules\Inventory\Models; use App\Core\BaseModel; class Warehouse extends BaseModel { protected string `$table = 'warehouses'; }" -Encoding UTF8

$stockModelPath = Join-Path $basePath "modules\Inventory\Models\InventoryStock.php"
Set-Content -Path $stockModelPath -Value "<?php namespace Modules\Inventory\Models; use App\Core\BaseModel; class InventoryStock extends BaseModel { protected string `$table = 'inventory_stock'; }" -Encoding UTF8

# 3. Repositories
$stockRepoPath = Join-Path $basePath "modules\Inventory\Repositories\StockRepository.php"
$stockRepoContent = @'
<?php
namespace Modules\Inventory\Repositories;
use Modules\Inventory\Models\InventoryStock;
use PDO;
use Exception;

class StockRepository {
    private InventoryStock $model;
    public function __construct(InventoryStock $model) { $this->model = $model; }

    public function recordMovement(int $productId, int $warehouseId, float $qty, string $type, int $userId, string $notes = ''): bool {
        $db = $this->model->getDb();
        try {
            $db->beginTransaction();

            // 1. Write the immutable movement log
            $stmtLog = $db->prepare("INSERT INTO stock_movements (product_id, warehouse_id, user_id, type, quantity, notes) VALUES (?, ?, ?, ?, ?, ?)");
            $stmtLog->execute([$productId, $warehouseId, $userId, $type, $qty, $notes]);

            // 2. Adjust the actual stock quantities (Upsert)
            // If type is 'out', we deduct. If 'in', we add.
            $modifier = ($type === 'out') ? -1 : 1;
            $actualQty = $qty * $modifier;

            $stmtStock = $db->prepare("
                INSERT INTO inventory_stock (product_id, warehouse_id, quantity) 
                VALUES (?, ?, ?)
                ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity)
            ");
            $stmtStock->execute([$productId, $warehouseId, $actualQty]);

            $db->commit();
            return true;
        } catch (Exception $e) {
            $db->rollBack();
            throw $e;
        }
    }
}
'@
Set-Content -Path $stockRepoPath -Value $stockRepoContent -Encoding UTF8

# 4. Services
$inventoryServicePath = Join-Path $basePath "modules\Inventory\Services\InventoryManagerService.php"
$inventoryServiceContent = @'
<?php
namespace Modules\Inventory\Services;
use Modules\Inventory\Repositories\StockRepository;
use Exception;

class InventoryManagerService {
    private StockRepository $repo;
    public function __construct(StockRepository $repo) { $this->repo = $repo; }

    public function adjustStock(int $productId, int $warehouseId, float $qty, string $type, int $userId, string $notes = ''): bool {
        if ($qty <= 0) throw new Exception("Quantity must be greater than zero.");
        if (!in_array($type, ['in', 'out'])) throw new Exception("Invalid movement type.");

        // Additional business logic (e.g. check if out quantity exceeds available) can go here
        
        return $this->repo->recordMovement($productId, $warehouseId, $qty, $type, $userId, $notes);
    }
}
'@
Set-Content -Path $inventoryServicePath -Value $inventoryServiceContent -Encoding UTF8

# 5. Controllers
$stockControllerPath = Join-Path $basePath "modules\Inventory\Controllers\StockController.php"
$stockControllerContent = @'
<?php
namespace Modules\Inventory\Controllers;
use App\Core\BaseController;
use Modules\Inventory\Services\InventoryManagerService;
use Exception;

class StockController extends BaseController {
    private InventoryManagerService $service;
    public function __construct(InventoryManagerService $service) { $this->service = $service; }

    public function adjust() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            try {
                $productId = (int)$_POST['product_id'];
                $warehouseId = (int)$_POST['warehouse_id'];
                $qty = (float)$_POST['quantity'];
                $type = $_POST['type']; // 'in' or 'out'
                $userId = $_SESSION['user_id'] ?? 1;

                $this->service->adjustStock($productId, $warehouseId, $qty, $type, $userId, "Manual Adjustment");
                return $this->redirect('/inventory/stock/adjust?success=1');
            } catch (Exception $e) {
                return $this->view('stock/adjust', ['error' => $e->getMessage()], 'Inventory');
            }
        }
        return $this->view('stock/adjust', [], 'Inventory');
    }
}
'@
Set-Content -Path $stockControllerPath -Value $stockControllerContent -Encoding UTF8

# 6. Routes
$webRoutesPath = Join-Path $basePath "modules\Inventory\Routes\web.php"
Set-Content -Path $webRoutesPath -Value "<?php return [ 'GET /inventory/stock/adjust' => [Modules\Inventory\Controllers\StockController::class, 'adjust'], 'POST /inventory/stock/adjust' => [Modules\Inventory\Controllers\StockController::class, 'adjust'] ];" -Encoding UTF8

# 7. Views
$adjustViewPath = Join-Path $basePath "modules\Inventory\Views\stock\adjust.php"
$adjustViewContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Adjust Stock</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-4">
        <h2>Manual Stock Adjustment</h2>
        <div class="card shadow-sm mt-4 p-4">
            <?php if(isset($_GET['success'])): ?>
                <div class="alert alert-success">Stock updated successfully via Immutable Ledger.</div>
            <?php endif; ?>
            <?php if(isset($error)): ?>
                <div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
            <?php endif; ?>
            
            <form method="POST">
                <div class="mb-3">
                    <label>Product ID / Barcode Scan</label>
                    <input type="number" name="product_id" class="form-control" required autofocus>
                </div>
                <div class="mb-3">
                    <label>Warehouse ID</label>
                    <input type="number" name="warehouse_id" class="form-control" required>
                </div>
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label>Movement Type</label>
                        <select name="type" class="form-select">
                            <option value="in">Add (Stock In)</option>
                            <option value="out">Deduct (Stock Out)</option>
                        </select>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label>Quantity</label>
                        <input type="number" step="0.01" name="quantity" class="form-control" required>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary">Commit Adjustment</button>
            </form>
        </div>
    </div>
</body>
</html>
'@
Set-Content -Path $adjustViewPath -Value $adjustViewContent -Encoding UTF8

Write-Host "Inventory module Phase 1 built successfully."
