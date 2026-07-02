$basePath = "z:\xampp\htdocs\Enterprise-ERP-CRM-HRM-A-PM-B-0000"

# Directories
$dirs = @(
    "database\migrations",
    "modules\Accounting\Models",
    "modules\Accounting\Repositories",
    "modules\Accounting\Services",
    "modules\Accounting\Controllers",
    "modules\Accounting\Routes",
    "modules\Accounting\Views\journals",
    "modules\Accounting\Views\reports"
)

foreach ($dir in $dirs) {
    $fullPath = Join-Path $basePath $dir
    if (-not (Test-Path $fullPath)) { New-Item -ItemType Directory -Force -Path $fullPath | Out-Null }
}

# 1. Database Migration
$migrationPath = Join-Path $basePath "database\migrations\2026_01_08_000000_create_accounting_tables.php"
$migrationContent = @'
<?php
class CreateAccountingTables {
    public function up($db) {
        $sql = "
        -- Drop old basic table if it exists (from initial Master Data)
        DROP TABLE IF EXISTS journal_entries;
        
        CREATE TABLE financial_years (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(50) NOT NULL,
            start_date DATE NOT NULL,
            end_date DATE NOT NULL,
            is_closed BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE journal_entries (
            id INT AUTO_INCREMENT PRIMARY KEY,
            reference_number VARCHAR(100) NOT NULL UNIQUE,
            description TEXT,
            entry_date DATE NOT NULL,
            total_amount DECIMAL(15,4) NOT NULL DEFAULT 0.0000,
            status ENUM('draft', 'posted', 'voided') DEFAULT 'draft',
            created_by INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE journal_entry_lines (
            id INT AUTO_INCREMENT PRIMARY KEY,
            journal_entry_id INT NOT NULL,
            account_id INT NOT NULL,
            description VARCHAR(255),
            debit DECIMAL(15,4) NOT NULL DEFAULT 0.0000,
            credit DECIMAL(15,4) NOT NULL DEFAULT 0.0000,
            FOREIGN KEY (journal_entry_id) REFERENCES journal_entries(id) ON DELETE CASCADE,
            FOREIGN KEY (account_id) REFERENCES chart_of_accounts(id) ON DELETE RESTRICT
        );
        ";
        $db->exec($sql);
    }
    public function down($db) {
        $db->exec("DROP TABLE IF EXISTS journal_entry_lines, journal_entries, financial_years;");
    }
}
'@
Set-Content -Path $migrationPath -Value $migrationContent -Encoding UTF8

# 2. Models
$jeModelPath = Join-Path $basePath "modules\Accounting\Models\JournalEntry.php"
Set-Content -Path $jeModelPath -Value "<?php namespace Modules\Accounting\Models; use App\Core\BaseModel; class JournalEntry extends BaseModel { protected string `$table = 'journal_entries'; }" -Encoding UTF8

$jelModelPath = Join-Path $basePath "modules\Accounting\Models\JournalEntryLine.php"
Set-Content -Path $jelModelPath -Value "<?php namespace Modules\Accounting\Models; use App\Core\BaseModel; class JournalEntryLine extends BaseModel { protected string `$table = 'journal_entry_lines'; }" -Encoding UTF8

$coaModelPath = Join-Path $basePath "modules\Accounting\Models\ChartOfAccount.php"
Set-Content -Path $coaModelPath -Value "<?php namespace Modules\Accounting\Models; use App\Core\BaseModel; class ChartOfAccount extends BaseModel { protected string `$table = 'chart_of_accounts'; }" -Encoding UTF8

# 3. Repositories
$journalRepoPath = Join-Path $basePath "modules\Accounting\Repositories\JournalRepository.php"
$journalRepoContent = @'
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
'@
Set-Content -Path $journalRepoPath -Value $journalRepoContent -Encoding UTF8

$ledgerRepoPath = Join-Path $basePath "modules\Accounting\Repositories\LedgerRepository.php"
$ledgerRepoContent = @'
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
'@
Set-Content -Path $ledgerRepoPath -Value $ledgerRepoContent -Encoding UTF8

# 4. Services
$accountingServicePath = Join-Path $basePath "modules\Accounting\Services\AccountingService.php"
$accountingServiceContent = @'
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
'@
Set-Content -Path $accountingServicePath -Value $accountingServiceContent -Encoding UTF8

$reportServicePath = Join-Path $basePath "modules\Accounting\Services\ReportService.php"
$reportServiceContent = @'
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
'@
Set-Content -Path $reportServicePath -Value $reportServiceContent -Encoding UTF8

# 5. Controllers
$journalControllerPath = Join-Path $basePath "modules\Accounting\Controllers\JournalController.php"
$journalControllerContent = @'
<?php
namespace Modules\Accounting\Controllers;
use App\Core\BaseController;
use Modules\Accounting\Services\AccountingService;
use Exception;

class JournalController extends BaseController {
    private AccountingService $service;
    public function __construct(AccountingService $service) { $this->service = $service; }

    public function create() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            try {
                // In reality, this would parse an array of lines from $_POST
                $lines = [
                    ['account_id' => 1, 'description' => 'Office Supplies', 'debit' => 150.00, 'credit' => 0.00],
                    ['account_id' => 2, 'description' => 'Cash', 'debit' => 0.00, 'credit' => 150.00]
                ];
                $id = $this->service->postJournalEntry('Bought office supplies', date('Y-m-d'), $lines);
                return $this->redirect("/accounting/journals/$id?success=1");
            } catch (Exception $e) {
                return $this->view('journals/create', ['error' => $e->getMessage()], 'Accounting');
            }
        }
        return $this->view('journals/create', [], 'Accounting');
    }
}
'@
Set-Content -Path $journalControllerPath -Value $journalControllerContent -Encoding UTF8

# 6. Routes
$webRoutesPath = Join-Path $basePath "modules\Accounting\Routes\web.php"
Set-Content -Path $webRoutesPath -Value "<?php return [ 'GET /accounting/journal/create' => [Modules\Accounting\Controllers\JournalController::class, 'create'], 'POST /accounting/journal/create' => [Modules\Accounting\Controllers\JournalController::class, 'create'] ];" -Encoding UTF8

# 7. Views
$createJournalView = Join-Path $basePath "modules\Accounting\Views\journals\create.php"
$createJournalViewContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>New Journal Entry - Accounting</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-4">
        <h2>Create Journal Entry</h2>
        <?php if(isset($error)): ?>
            <div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
        <?php endif; ?>
        <form method="POST">
            <!-- Dynamic JS line items go here for debit/credit -->
            <button type="submit" class="btn btn-primary">Post Entry</button>
        </form>
    </div>
</body>
</html>
'@
Set-Content -Path $createJournalView -Value $createJournalViewContent -Encoding UTF8

Write-Host "Accounting module Phase 1 built successfully."
