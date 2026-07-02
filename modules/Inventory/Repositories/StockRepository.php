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
