<?php
namespace Modules\CRM\Services;

use Modules\CRM\Repositories\LeadRepository;
use Modules\CRM\Validators\LeadValidator;
use Exception;

class LeadService {
    private $repo;

    public function __construct() {
        $this->repo = new LeadRepository();
    }

    public function getLeads() {
        return $this->repo->getAll();
    }

    public function createLead(array $data) {
        $errors = LeadValidator::validate($data);
        if (!empty($errors)) {
            throw new Exception(implode(', ', $errors));
        }
        return $this->repo->create($data);
    }

    public function updateLead(int $id, array $data) {
        $errors = LeadValidator::validate($data);
        if (!empty($errors)) {
            throw new Exception(implode(', ', $errors));
        }
        return $this->repo->update($id, $data);
    }

    public function deleteLead(int $id) {
        return $this->repo->delete($id);
    }
}