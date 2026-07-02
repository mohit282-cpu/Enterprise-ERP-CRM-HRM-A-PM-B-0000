<?php
namespace Modules\Billing\Repositories;
use Modules\Billing\Models\Invoice;
use PDO;

class InvoiceRepository {
    private Invoice $model;
    public function __construct(Invoice $model) { $this->model = $model; }

    public function createInvoice(array $data): int {
        $stmt = $this->model->getDb()->prepare("
            INSERT INTO invoices (invoice_number, customer_id, subtotal, tax_total, grand_total, status, issue_date, due_date) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([
            $data['invoice_number'], $data['customer_id'], $data['subtotal'], 
            $data['tax_total'], $data['grand_total'], 'draft', $data['issue_date'], $data['due_date']
        ]);
        return (int)$this->model->getDb()->lastInsertId();
    }
}
