# Contributing Guidelines

Welcome to the Sovryx OS development team. Please follow these strict guidelines to maintain the integrity of the ERP.

## 1. Coding Standards
* We strictly adhere to **PSR-12** coding standards.
* Type hinting is **MANDATORY** for all function arguments and return types (PHP 8.3).
* No raw SQL queries inside Controllers. All database interaction must occur inside `Repositories`.

## 2. The Modular Pattern
If you are adding a new feature, do not place it in the core `app/` folder. Create a new module in the `modules/` directory following the HMVC structure (`Controllers/`, `Models/`, `Repositories/`, `Services/`, `Views/`, `Routes/`).

## 3. Pull Requests
* Branch off `develop`.
* Ensure all PHPUnit tests pass (`./vendor/bin/phpunit`).
* Write unit tests for any new Services, and Feature tests for any new Repositories.
