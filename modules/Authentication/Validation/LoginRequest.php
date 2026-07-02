<?php

namespace Modules\Authentication\Validation;

class LoginRequest {
    public function validate(array $data): array {
        $errors = [];
        if (empty($data['email']) || !filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            $errors['email'] = 'Valid email is required.';
        }
        if (empty($data['password'])) {
            $errors['password'] = 'Password is required.';
        }
        return $errors;
    }
}
