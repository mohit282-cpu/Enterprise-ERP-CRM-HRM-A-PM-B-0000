<?php
namespace Modules\Accounting\Services;
use Modules\Accounting\Repositories\LedgerRepository;

class ReportService {
    private LedgerRepository $repo;
    public function __construct(LedgerRepository $repo) { $this->repo = $repo; }

    public function generateProfitAndLoss(string $dateTo): array {
        // Aggregates revenue and expense accounts from the ledger
        $trialBalance = $this->repo->getTrialBalance($dateTo);
        $revenue = 0; $expenses = 0;
        
        foreach($trialBalance as $acc) {
            if ($acc['type'] === 'revenue') $revenue += ($acc['total_credit'] - $acc['total_debit']);
            if ($acc['type'] === 'expense') $expenses += ($acc['total_debit'] - $acc['total_credit']);
        }
        
        return [
            'revenue' => $revenue,
            'expenses' => $expenses,
            'net_profit' => $revenue - $expenses
        ];
    }
}
