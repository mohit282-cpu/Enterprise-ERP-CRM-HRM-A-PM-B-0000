<?php
namespace Modules\Accounting\Services;
use Modules\Accounting\Repositories\JournalRepository;
use Exception;

class AccountingService {
    private JournalRepository $repo;
    public function __construct(JournalRepository $repo) { $this->repo = $repo; }

    public function postJournalEntry(string $description, string $date, array $lines): int {
        $totalDebit = 0.00;
        $totalCredit = 0.00;

        foreach ($lines as $line) {
            $totalDebit += (float)$line['debit'];
            $totalCredit += (float)$line['credit'];
        }

        // STRICT DOUBLE ENTRY VALIDATION
        if (round($totalDebit, 4) !== round($totalCredit, 4)) {
            throw new Exception("Double Entry Violation: Total Debits ($totalDebit) do not equal Total Credits ($totalCredit).");
        }

        if ($totalDebit <= 0) {
            throw new Exception("Journal entry must have a value greater than zero.");
        }

        $header = [
            'reference_number' => 'JE-' . strtoupper(uniqid()),
            'description' => $description,
            'entry_date' => $date,
            'total_amount' => $totalDebit
        ];

        return $this->repo->createTransaction($header, $lines);
    }
}
