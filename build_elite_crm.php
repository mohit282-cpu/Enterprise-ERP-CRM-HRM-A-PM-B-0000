<?php
$moduleDir = __DIR__ . '/modules/CRM';

// Create missing directories
$dirs = ['Models', 'Validators', 'Repositories', 'Services', 'Controllers', 'Views/leads', 'Tests'];
foreach ($dirs as $dir) {
    if (!is_dir($moduleDir . '/' . $dir)) {
        mkdir($moduleDir . '/' . $dir, 0777, true);
    }
}

// 1. Model
$modelContent = <<<PHP
<?php
namespace Modules\CRM\Models;

class Lead {
    public \$id;
    public \$tenant_id;
    public \$name;
    public \$company;
    public \$email;
    public \$phone;
    public \$source;
    public \$expected_revenue;
    public \$stage;
    public \$notes;
    public \$created_at;
}
PHP;
file_put_contents($moduleDir . '/Models/Lead.php', $modelContent);

// 2. Validator
$validatorContent = <<<PHP
<?php
namespace Modules\CRM\Validators;

class LeadValidator {
    public static function validate(array \$data) {
        \$errors = [];
        if (empty(\$data['name'])) \$errors[] = "Name is required.";
        if (empty(\$data['email']) || !filter_var(\$data['email'], FILTER_VALIDATE_EMAIL)) \$errors[] = "Valid email is required.";
        if (isset(\$data['expected_revenue']) && !is_numeric(\$data['expected_revenue'])) \$errors[] = "Expected revenue must be numeric.";
        return \$errors;
    }
}
PHP;
file_put_contents($moduleDir . '/Validators/LeadValidator.php', $validatorContent);

// 3. Repository
$repoContent = <<<PHP
<?php
namespace Modules\CRM\Repositories;

use App\Core\Database;
use App\Core\TenantContext;
use PDO;

class LeadRepository {
    private \$db;

    public function __construct() {
        \$this->db = Database::getInstance();
    }

    public function getAll() {
        \$tenantId = TenantContext::getInstance()->getTenantId();
        \$stmt = \$this->db->prepare("SELECT * FROM crm_leads WHERE tenant_id = ? ORDER BY created_at DESC");
        \$stmt->execute([\$tenantId]);
        return \$stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function create(array \$data) {
        \$tenantId = TenantContext::getInstance()->getTenantId();
        \$stmt = \$this->db->prepare("
            INSERT INTO crm_leads (tenant_id, name, company, email, phone, source, expected_revenue, stage, notes) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        return \$stmt->execute([
            \$tenantId,
            \$data['name'] ?? '',
            \$data['company'] ?? null,
            \$data['email'] ?? '',
            \$data['phone'] ?? null,
            \$data['source'] ?? 'Organic',
            \$data['expected_revenue'] ?? 0.00,
            \$data['stage'] ?? 'New',
            \$data['notes'] ?? null
        ]);
    }

    public function update(int \$id, array \$data) {
        \$tenantId = TenantContext::getInstance()->getTenantId();
        \$stmt = \$this->db->prepare("
            UPDATE crm_leads 
            SET name=?, company=?, email=?, phone=?, source=?, expected_revenue=?, stage=?, notes=? 
            WHERE id=? AND tenant_id=?
        ");
        return \$stmt->execute([
            \$data['name'] ?? '',
            \$data['company'] ?? null,
            \$data['email'] ?? '',
            \$data['phone'] ?? null,
            \$data['source'] ?? 'Organic',
            \$data['expected_revenue'] ?? 0.00,
            \$data['stage'] ?? 'New',
            \$data['notes'] ?? null,
            \$id,
            \$tenantId
        ]);
    }

    public function delete(int \$id) {
        \$tenantId = TenantContext::getInstance()->getTenantId();
        \$stmt = \$this->db->prepare("DELETE FROM crm_leads WHERE id=? AND tenant_id=?");
        return \$stmt->execute([\$id, \$tenantId]);
    }
}
PHP;
file_put_contents($moduleDir . '/Repositories/LeadRepository.php', $repoContent);

// 4. Service
$svcContent = <<<PHP
<?php
namespace Modules\CRM\Services;

use Modules\CRM\Repositories\LeadRepository;
use Modules\CRM\Validators\LeadValidator;
use Exception;

class LeadService {
    private \$repo;

    public function __construct() {
        \$this->repo = new LeadRepository();
    }

    public function getLeads() {
        return \$this->repo->getAll();
    }

    public function createLead(array \$data) {
        \$errors = LeadValidator::validate(\$data);
        if (!empty(\$errors)) {
            throw new Exception(implode(', ', \$errors));
        }
        return \$this->repo->create(\$data);
    }

    public function updateLead(int \$id, array \$data) {
        \$errors = LeadValidator::validate(\$data);
        if (!empty(\$errors)) {
            throw new Exception(implode(', ', \$errors));
        }
        return \$this->repo->update(\$id, \$data);
    }

    public function deleteLead(int \$id) {
        return \$this->repo->delete(\$id);
    }
}
PHP;
file_put_contents($moduleDir . '/Services/LeadService.php', $svcContent);

// 5. Controller
$ctrlContent = <<<PHP
<?php
namespace Modules\CRM\Controllers;

use App\Core\BaseController;
use Modules\CRM\Services\LeadService;

class LeadController extends BaseController {
    private \$service;

    public function __construct() {
        \$this->service = new LeadService();
    }

    public function index() {
        \$leads = \$this->service->getLeads();
        // Calculate pipeline metrics
        \$metrics = [
            'total' => count(\$leads),
            'new' => count(array_filter(\$leads, fn(\$l) => strtolower(\$l['stage']) === 'new')),
            'won' => count(array_filter(\$leads, fn(\$l) => strtolower(\$l['stage']) === 'won')),
            'revenue' => array_sum(array_column(\$leads, 'expected_revenue'))
        ];
        return \$this->view('index', ['leads' => \$leads, 'metrics' => \$metrics], 'CRM');
    }

    public function store() {
        if (\$_SERVER['REQUEST_METHOD'] === 'POST') {
            try {
                \$this->service->createLead(\$_POST);
                // Here we would set a flash message
            } catch (\Exception \$e) {
                // Here we would log the error and set an error flash message
            }
            header('Location: /crm/leads');
            exit;
        }
    }

    public function update() {
        if (\$_SERVER['REQUEST_METHOD'] === 'POST') {
            try {
                \$id = \$_POST['id'];
                unset(\$_POST['id']);
                \$this->service->updateLead((int)\$id, \$_POST);
            } catch (\Exception \$e) {
                // Handle error
            }
            header('Location: /crm/leads');
            exit;
        }
    }

    public function destroy() {
        if (\$_SERVER['REQUEST_METHOD'] === 'POST') {
            \$this->service->deleteLead((int)\$_POST['id']);
            header('Location: /crm/leads');
            exit;
        }
    }
}
PHP;
file_put_contents($moduleDir . '/Controllers/LeadController.php', $ctrlContent);

// 6. View
$viewContent = <<<PHP
<div class="container-fluid">
    <!-- Header -->
    <div class="row mb-4 align-items-center">
        <div class="col">
            <h2 class="h3 mb-0 text-gray-800">Lead Management</h2>
            <p class="text-muted mb-0">Track and manage your sales pipeline.</p>
        </div>
        <div class="col-auto">
            <button class="btn btn-primary shadow-sm" data-bs-toggle="modal" data-bs-target="#leadModal" onclick="openModal()">
                <i class="fas fa-plus me-1"></i> New Lead
            </button>
        </div>
    </div>

    <!-- Metrics Cards -->
    <div class="row mb-4">
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-0 border-start border-primary border-4 shadow-sm h-100 py-2">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">Total Leads</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800"><?= \$metrics['total'] ?></div>
                        </div>
                        <div class="col-auto"><i class="fas fa-users fa-2x text-gray-300"></i></div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-0 border-start border-success border-4 shadow-sm h-100 py-2">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-success text-uppercase mb-1">Won Deals</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800"><?= \$metrics['won'] ?></div>
                        </div>
                        <div class="col-auto"><i class="fas fa-trophy fa-2x text-gray-300"></i></div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-0 border-start border-info border-4 shadow-sm h-100 py-2">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-info text-uppercase mb-1">New Pipeline</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800"><?= \$metrics['new'] ?></div>
                        </div>
                        <div class="col-auto"><i class="fas fa-clipboard-list fa-2x text-gray-300"></i></div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-0 border-start border-warning border-4 shadow-sm h-100 py-2">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">Expected Revenue</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800">\$<?= number_format(\$metrics['revenue'], 2) ?></div>
                        </div>
                        <div class="col-auto"><i class="fas fa-dollar-sign fa-2x text-gray-300"></i></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Data Table -->
    <div class="card shadow-sm border-0 mb-4">
        <div class="card-header py-3 bg-white border-bottom-0">
            <h6 class="m-0 font-weight-bold text-primary">All Leads</h6>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle" id="leadsTable" width="100%" cellspacing="0">
                    <thead class="table-light">
                        <tr>
                            <th>Name</th>
                            <th>Company</th>
                            <th>Email</th>
                            <th>Source</th>
                            <th>Stage</th>
                            <th>Revenue</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach (\$leads as \$row): ?>
                        <tr>
                            <td class="fw-bold"><?= htmlspecialchars(\$row['name']) ?></td>
                            <td><?= htmlspecialchars(\$row['company'] ?? '-') ?></td>
                            <td><a href="mailto:<?= htmlspecialchars(\$row['email']) ?>"><?= htmlspecialchars(\$row['email']) ?></a></td>
                            <td><span class="badge bg-secondary"><?= htmlspecialchars(\$row['source']) ?></span></td>
                            <td>
                                <?php 
                                    \$stageClass = 'bg-primary';
                                    if(strtolower(\$row['stage']) == 'won') \$stageClass = 'bg-success';
                                    if(strtolower(\$row['stage']) == 'lost') \$stageClass = 'bg-danger';
                                    if(strtolower(\$row['stage']) == 'qualified') \$stageClass = 'bg-info';
                                ?>
                                <span class="badge <?= \$stageClass ?>"><?= htmlspecialchars(ucfirst(\$row['stage'])) ?></span>
                            </td>
                            <td>\$<?= number_format(\$row['expected_revenue'], 2) ?></td>
                            <td class="text-end">
                                <button onclick='openModal(<?= json_encode(\$row) ?>)' class="btn btn-sm btn-light text-primary me-1"><i class="fas fa-edit"></i></button>
                                <form method="POST" action="/crm/leads/delete" class="d-inline">
                                    <input type="hidden" name="id" value="<?= \$row['id'] ?>">
                                    <button type="submit" class="btn btn-sm btn-light text-danger" onclick="return confirm('Delete this lead permanently?')"><i class="fas fa-trash"></i></button>
                                </form>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Add/Edit Modal -->
<div class="modal fade" id="leadModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <form method="POST" action="/crm/leads" id="leadForm">
            <input type="hidden" name="id" id="form_id">
            <div class="modal-content border-0 shadow-lg">
                <div class="modal-header bg-light border-0">
                    <h5 class="modal-title fw-bold" id="modalTitle">Add New Lead</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-bold">Full Name <span class="text-danger">*</span></label>
                            <input type="text" name="name" id="form_name" class="form-control" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-bold">Company</label>
                            <input type="text" name="company" id="form_company" class="form-control">
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-bold">Email <span class="text-danger">*</span></label>
                            <input type="email" name="email" id="form_email" class="form-control" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-bold">Phone</label>
                            <input type="text" name="phone" id="form_phone" class="form-control">
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label class="form-label fw-bold">Source</label>
                            <select name="source" id="form_source" class="form-select">
                                <option value="Organic">Organic Search</option>
                                <option value="Referral">Referral</option>
                                <option value="Social">Social Media</option>
                                <option value="Direct">Direct Traffic</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label fw-bold">Stage</label>
                            <select name="stage" id="form_stage" class="form-select">
                                <option value="New">New</option>
                                <option value="Contacted">Contacted</option>
                                <option value="Qualified">Qualified</option>
                                <option value="Proposal">Proposal Sent</option>
                                <option value="Won">Closed Won</option>
                                <option value="Lost">Closed Lost</option>
                            </select>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label fw-bold">Expected Rev. (\$)</label>
                            <input type="number" step="0.01" name="expected_revenue" id="form_expected_revenue" class="form-control" value="0.00">
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Notes</label>
                        <textarea name="notes" id="form_notes" class="form-control" rows="3"></textarea>
                    </div>
                </div>
                <div class="modal-footer border-0 bg-light">
                    <button type="button" class="btn btn-link text-muted text-decoration-none" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary px-4">Save Lead</button>
                </div>
            </div>
        </form>
    </div>
</div>

<script>
    function openModal(row = null) {
        let form = document.getElementById('leadForm');
        let title = document.getElementById('modalTitle');
        
        if (row) {
            title.innerText = 'Edit Lead';
            form.action = '/crm/leads/update';
            document.getElementById('form_id').value = row.id;
            document.getElementById('form_name').value = row.name;
            document.getElementById('form_company').value = row.company;
            document.getElementById('form_email').value = row.email;
            document.getElementById('form_phone').value = row.phone;
            document.getElementById('form_source').value = row.source;
            document.getElementById('form_stage').value = row.stage;
            document.getElementById('form_expected_revenue').value = row.expected_revenue;
            document.getElementById('form_notes').value = row.notes;
            
            var modal = new bootstrap.Modal(document.getElementById('leadModal'));
            modal.show();
        } else {
            title.innerText = 'Add New Lead';
            form.action = '/crm/leads';
            form.reset();
            document.getElementById('form_id').value = '';
        }
    }
</script>
PHP;
file_put_contents($moduleDir . '/Views/leads/index.php', $viewContent);

// 7. Docs
$docsContent = <<<MD
# CRM Module (Elite Standard)

## Business Requirements
- Complete management of Sales Pipeline.
- Multi-tenant data isolation.
- Lead lifecycle tracking (New -> Won/Lost).
- Financial forecasting (Expected Revenue).

## Architecture
- **Model:** `Lead.php` (Entity definition)
- **Validator:** `LeadValidator.php` (Strict business rule validation)
- **Repository:** `LeadRepository.php` (Complex PDO logic, tenant isolated)
- **Service:** `LeadService.php` (Business layer orchestration)
- **Controller:** `LeadController.php` (HTTP interface)

## UI
- Bootstrap 5 offcanvas/modal forms.
- DataTables for searching/sorting (to be implemented via layout).
- Aggregate metrics cards.

## Future Improvements
- Integrate PHPMailer to send welcome emails on 'Qualified' stage.
- Add activity logging for state transitions.
MD;
file_put_contents($moduleDir . '/README.md', $docsContent);

echo "Elite CRM module built successfully.\n";
