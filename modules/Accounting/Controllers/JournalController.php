<?php
namespace Modules\Accounting\Controllers;
use App\Core\BaseController;
use Modules\Accounting\Services\AccountingService;
use Exception;

class JournalController extends BaseController {
    private AccountingService $service;
    public function __construct(AccountingService $service) { $this->service = $service; }

    public function create() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            try {
                // In reality, this would parse an array of lines from $_POST
                $lines = [
                    ['account_id' => 1, 'description' => 'Office Supplies', 'debit' => 150.00, 'credit' => 0.00],
                    ['account_id' => 2, 'description' => 'Cash', 'debit' => 0.00, 'credit' => 150.00]
                ];
                $id = $this->service->postJournalEntry('Bought office supplies', date('Y-m-d'), $lines);
                return $this->redirect("/accounting/journals/$id?success=1");
            } catch (Exception $e) {
                return $this->view('journals/create', ['error' => $e->getMessage()], 'Accounting');
            }
        }
        return $this->view('journals/create', [], 'Accounting');
    }
}
