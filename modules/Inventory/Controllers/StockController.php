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
