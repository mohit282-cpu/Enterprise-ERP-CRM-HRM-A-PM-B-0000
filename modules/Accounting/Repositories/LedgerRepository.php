<?php
namespace Modules\Accounting\Repositories;
use Modules\Accounting\Models\ChartOfAccount;
use PDO;

class LedgerRepository {
    private ChartOfAccount $model;
    public function __construct(ChartOfAccount $model) { $this->model = $model; }

    public function getTrialBalance(string $dateTo): array {
        $sql = "
            SELECT a.code, a.name, a.type,
                   SUM(l.debit) as total_debit, 
                   SUM(l.credit) as total_credit
            FROM chart_of_accounts a
            LEFT JOIN journal_entry_lines l ON a.id = l.account_id
            LEFT JOIN journal_entries je ON l.journal_entry_id = je.id
            WHERE je.entry_date <= ? AND je.status = 'posted'
            GROUP BY a.id
        ";
        $stmt = $this->model->getDb()->prepare($sql);
        $stmt->execute([$dateTo]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
