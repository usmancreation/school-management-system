# School Management System - PHP REST API
## PostgreSQL Connection Instructions

This PHP backend is designed for the School Management System and connects directly to the **PostgreSQL `school_erp` database** running in pgAdmin 4.

### Requirements:
1. PHP 8.1+ with `pdo_pgsql` extension enabled in `php.ini`.
2. PostgreSQL 15/16/18 running on port `5432`.

### Running Locally:
```bash
cd backend_php
php -S 127.0.0.1:8080
```

### Endpoints:
- `POST /api/auth/login.php`
- `GET /api/dashboard/metrics.php`
- `GET /api/students/index.php`
- `POST /api/students/index.php`
- `GET /api/teachers/index.php`
- `GET /api/fees/invoices.php`
- `POST /api/fees/collect.php`
- `GET /api/attendance/index.php`
- `POST /api/attendance/index.php`
