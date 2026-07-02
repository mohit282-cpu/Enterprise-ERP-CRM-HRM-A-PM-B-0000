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
