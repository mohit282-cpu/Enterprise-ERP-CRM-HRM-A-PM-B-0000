# Authentication & User Management Module

This module serves as the foundational security layer for Sovryx OS, handling authentication, authorization (RBAC), and user administration.

## Features
- Login, Registration, Logout
- Role-Based Access Control (RBAC) via `CheckPermission` Middleware
- Organization Management (Branches, Departments, Teams)
- Session Management & Timeout
- Audit Logging & Security Tracking

## Architecture
- **Controllers**: Handle HTTP routing (`AuthController`, `UserController`)
- **Services**: Contain business logic (`AuthService`)
- **Models**: Database entities (`User`, `Role`, `Permission`)
- **Middleware**: Guard routes (`RequireAuth`, `CheckPermission`)

## Future Roadmap
- Implementation of TOTP (Google Authenticator) 2FA
- Integration of SSO (SAML/OAuth)
- Geo-location tracking for active sessions
