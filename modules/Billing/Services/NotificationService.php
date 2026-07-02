<?php
namespace Modules\Billing\Services;

class NotificationService {
    /**
     * Stub for Phase 2: WhatsApp & Email integrations
     */
    public function sendInvoiceViaWhatsApp(int $invoiceId, string $phone): bool {
        // e.g. Twilio API call
        return true;
    }

    public function sendInvoiceViaEmail(int $invoiceId, string $email): bool {
        // e.g. PHPMailer or SMTP service
        return true;
    }
}
