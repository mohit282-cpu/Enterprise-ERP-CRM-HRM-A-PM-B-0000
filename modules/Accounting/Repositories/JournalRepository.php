<?php
namespace Modules\Accounting\Repositories;
use Modules\Accounting\Models\JournalEntry;
use PDO;
use Exception;

class JournalRepository {
    private JournalEntry $model;
    public function __construct(JournalEntry $model) { $this->model = $model; }

    public function createTransaction(array $header, array $lines): int {
        $db = $this->model->getDb();
        try {
            $db->beginTransaction();

            // Insert Header
            $stmt = $db->prepare("INSERT INTO journal_entries (reference_number, description, entry_date, total_amount, status) VALUES (?, ?, ?, ?, 'posted')");
            $stmt->execute([$header['reference_number'], $header['description'], $header['entry_date'], $header['total_amount']]);
            $journalId = (int)$db->lastInsertId();

            // Insert Lines
            $stmtLine = $db->prepare("INSERT INTO journal_entry_lines (journal_entry_id, account_id, description, debit, credit) VALUES (?, ?, ?, ?, ?)");
            foreach ($lines as $line) {
                $stmtLine->execute([$journalId, $line['account_id'], $line['description'], $line['debit'], $line['credit']]);
            }

            $db->commit();
            return $journalId;
        } catch (Exception $e) {
            $db->rollBack();
            throw $e;
        }
    }
}
