<?php
namespace Modules\CRM\Models;

class Lead {
    public $id;
    public $tenant_id;
    public $name;
    public $company;
    public $email;
    public $phone;
    public $source;
    public $expected_revenue;
    public $stage;
    public $notes;
    public $created_at;
}