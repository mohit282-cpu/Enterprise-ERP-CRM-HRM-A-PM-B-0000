# Production Deployment

When deploying Sovryx OS to a production Linux server (Ubuntu/Nginx):

## 1. Document Root
Configure Nginx to point the root strictly to the `/public` directory. **NEVER** expose the `/app`, `/modules`, or `/database` directories to the public web.

## 2. Environment Variables
Ensure the production `.env` file is heavily guarded (chmod 600) and contains the live database credentials.

## 3. SSL/TLS
The system architecture assumes HTTPS. The global `SecurityMiddleware` enforces `Strict-Transport-Security`. If you deploy without an SSL certificate, modern browsers will reject connections to the ERP.
