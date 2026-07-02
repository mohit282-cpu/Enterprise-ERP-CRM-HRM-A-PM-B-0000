# KnowledgeBase Module

Core module for handling KnowledgeBase specific business logic.

## Architecture
This module follows the Sovryx OS HMVC Architecture, implementing:
- **Controllers:** HTTP Request handling
- **Services:** Business Logic processing
- **Repositories:** Database interaction (Repository Pattern)
- **Models:** Data structures
- **Views:** Module-specific UI components

## Developer Guidelines
- Ensure all business logic remains in the Services/ directory.
- Database access must only happen via the Repositories/.
- Adhere to PSR-12 and strict typing for PHP 8.3+.
