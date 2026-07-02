<?php
namespace Tests\Feature;

use Tests\TestCase;
use Modules\Accounting\Services\AccountingService;
use Modules\Accounting\Repositories\LedgerRepository;
use Exception;

class AccountingLedgerTest extends TestCase {
    
    public function test_it_rejects_unbalanced_journal_entries() {
        $this->expectException(Exception::class);
        $this->expectExceptionMessage("Debit and Credit totals must be equal.");

        // We mock the repository since we don't have a real DB in this stub
        $repo = $this->createMock(LedgerRepository::class);
        $service = new AccountingService($repo);

        $lines = [
            ['account_id' => 1, 'debit' => 100, 'credit' => 0],
            ['account_id' => 2, 'debit' => 0, 'credit' => 50] // Unbalanced by 50
        ];

        $service->postJournalEntry('Test Entry', '2026-07-02', $lines);
    }
}
