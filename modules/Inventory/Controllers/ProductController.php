<?php
namespace Modules\Inventory\Controllers;

use App\Core\BaseController;
use Modules\Inventory\Services\ProductService;

class ProductController extends BaseController {
    private ProductService $service;
    
    public function __construct(ProductService $service) {
        $this->service = $service;
    }
    
    public function index() {
        $data = $this->service->getAllRecords();
        return $this->view('products/index', ['products' => $data], 'Inventory');
    }
}
