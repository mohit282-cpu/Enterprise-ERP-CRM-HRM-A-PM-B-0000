<?php
namespace Modules\Billing\Services;

class PdfService {
    /**
     * Abstracted PDF generator. Can hook into DomPDF or mpdf later.
     */
    public function generateInvoicePdf(int $invoiceId): string {
        // Stub for Phase 2: Render HTML template and stream PDF
        return "PDF_STREAM_DATA_FOR_INVOICE_$invoiceId";
    }
}
