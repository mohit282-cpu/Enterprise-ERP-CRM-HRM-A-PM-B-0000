<?php
namespace Modules\Billing\Services;
use Modules\Billing\Repositories\InvoiceRepository;

class InvoiceService {
    private InvoiceRepository $repo;
    const VAT_RATE = 0.13; // 13% VAT

    public function __construct(InvoiceRepository $repo) { $this->repo = $repo; }

    public function generateInvoice(array $data): int {
        // Calculate VAT 13%
        $subtotal = (float)$data['subtotal'];
        $tax = $subtotal * self::VAT_RATE;
        $grandTotal = $subtotal + $tax;

        $invoiceData = [
            'invoice_number' => 'INV-' . strtoupper(uniqid()),
            'customer_id' => $data['customer_id'],
            'subtotal' => $subtotal,
            'tax_total' => $tax,
            'grand_total' => $grandTotal,
            'issue_date' => date('Y-m-d'),
            'due_date' => date('Y-m-d', strtotime('+30 days'))
        ];

        return $this->repo->createInvoice($invoiceData);
    }
}
