<?php
namespace Modules\CRM\Validators;

class LeadValidator {
    public static function validate(array $data) {
        $errors = [];
        if (empty($data['name'])) $errors[] = "Name is required.";
        if (empty($data['email']) || !filter_var($data['email'], FILTER_VALIDATE_EMAIL)) $errors[] = "Valid email is required.";
        if (isset($data['expected_revenue']) && !is_numeric($data['expected_revenue'])) $errors[] = "Expected revenue must be numeric.";
        return $errors;
    }
}