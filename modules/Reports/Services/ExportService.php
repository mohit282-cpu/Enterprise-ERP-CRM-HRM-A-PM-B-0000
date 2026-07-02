<?php
namespace Modules\Reports\Services;

class ExportService {
    /**
     * Stub for Phase 2: Will integrate DomPDF to convert HTML reports to PDF downloads
     */
    public function generatePdf(string $htmlContent, string $filename): string {
        return "PDF generation coming in Phase 2 for $filename";
    }

    /**
     * Stub for Phase 2: Will integrate PhpSpreadsheet to convert arrays to .xlsx downloads
     */
    public function generateExcel(array $data, string $filename): string {
        return "Excel generation coming in Phase 2 for $filename";
    }
}
