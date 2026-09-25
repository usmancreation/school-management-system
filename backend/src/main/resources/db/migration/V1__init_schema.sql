-- =============================================================================
-- Enterprise School Management ERP - PostgreSQL 16 Normalized Schema
-- Migration: V1__init_schema.sql
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- -----------------------------------------------------------------------------
-- 1. INSTITUTION & GLOBAL SETTINGS
-- -----------------------------------------------------------------------------
CREATE TABLE school_profile (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_name VARCHAR(255) NOT NULL,
    affiliation_code VARCHAR(100),
    registration_number VARCHAR(100) UNIQUE,
    email VARCHAR(255) NOT NULL,
    phone_primary VARCHAR(30) NOT NULL,
    phone_secondary VARCHAR(30),
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'United States',
    website_url VARCHAR(255),
    logo_path VARCHAR(500),
    currency_code VARCHAR(10) NOT NULL DEFAULT 'USD',
    currency_symbol VARCHAR(10) NOT NULL DEFAULT '$',
    timezone VARCHAR(50) NOT NULL DEFAULT 'UTC',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE academic_years (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE, -- e.g. '2025-2026'
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL DEFAULT FALSE,
    is_locked BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_academic_dates CHECK (end_date > start_date)
);

-- -----------------------------------------------------------------------------
-- 2. SECURITY & RBAC
-- -----------------------------------------------------------------------------
CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    module VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL UNIQUE, -- e.g. 'ROLE_SUPER_ADMIN', 'ROLE_TEACHER'
    description VARCHAR(255),
    is_system_role BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE role_permissions (
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(30),
    avatar_url VARCHAR(500),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_locked BOOLEAN NOT NULL DEFAULT FALSE,
    failed_attempts INT NOT NULL DEFAULT 0,
    last_login_at TIMESTAMPTZ,
    password_reset_token VARCHAR(255),
    password_reset_expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE user_roles (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_name VARCHAR(100) NOT NULL,
    entity_id VARCHAR(100),
    details JSONB,
    ip_address VARCHAR(50),
    user_agent VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 3. ACADEMIC STRUCTURE
-- -----------------------------------------------------------------------------
CREATE TABLE classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL, -- e.g. 'Grade 10'
    numeric_order INT NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL, -- e.g. 'A', 'B'
    room_number VARCHAR(50),
    capacity INT NOT NULL DEFAULT 40,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_class_section UNIQUE (class_id, name)
);

CREATE TABLE subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    code VARCHAR(50) NOT NULL UNIQUE,
    type VARCHAR(50) NOT NULL DEFAULT 'THEORY', -- 'THEORY', 'PRACTICAL', 'BOTH'
    is_elective BOOLEAN NOT NULL DEFAULT FALSE,
    pass_marks DECIMAL(5, 2) NOT NULL DEFAULT 33.00,
    total_marks DECIMAL(5, 2) NOT NULL DEFAULT 100.00,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE class_subjects (
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    PRIMARY KEY (class_id, subject_id)
);

-- -----------------------------------------------------------------------------
-- 4. STAFF & TEACHERS
-- -----------------------------------------------------------------------------
CREATE TABLE departments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE staff (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE SET NULL,
    department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
    employee_code VARCHAR(100) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    gender VARCHAR(20) NOT NULL,
    date_of_birth DATE NOT NULL,
    date_of_joining DATE NOT NULL,
    designation VARCHAR(100) NOT NULL,
    qualification VARCHAR(255),
    national_id VARCHAR(100),
    emergency_contact VARCHAR(30),
    basic_salary DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    bank_account_number VARCHAR(100),
    bank_name VARCHAR(100),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, ON_LEAVE, TERMINATED, RESIGNED
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE section_teachers (
    section_id UUID NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
    staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
    is_class_teacher BOOLEAN NOT NULL DEFAULT FALSE,
    academic_year_id UUID NOT NULL REFERENCES academic_years(id) ON DELETE CASCADE,
    PRIMARY KEY (section_id, staff_id, academic_year_id)
);

CREATE TABLE timetable_slots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    academic_year_id UUID NOT NULL REFERENCES academic_years(id) ON DELETE CASCADE,
    section_id UUID NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
    day_of_week VARCHAR(20) NOT NULL, -- MONDAY, TUESDAY, etc.
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room_number VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_slot_time CHECK (end_time > start_time)
);

-- -----------------------------------------------------------------------------
-- 5. STUDENT LIFECYCLE
-- -----------------------------------------------------------------------------
CREATE TABLE students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE SET NULL,
    admission_number VARCHAR(100) NOT NULL UNIQUE,
    admission_date DATE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    gender VARCHAR(20) NOT NULL,
    date_of_birth DATE NOT NULL,
    blood_group VARCHAR(10),
    religion VARCHAR(50),
    caste VARCHAR(50),
    nationality VARCHAR(50) DEFAULT 'American',
    national_id VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(30),
    current_address TEXT,
    permanent_address TEXT,
    medical_notes TEXT,
    photo_url VARCHAR(500),
    status VARCHAR(50) NOT NULL DEFAULT 'ENROLLED', -- ENROLLED, GRADUATED, TRANSFERRED, SUSPENDED
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE guardians (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE SET NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    relation VARCHAR(50) NOT NULL, -- FATHER, MOTHER, LEGAL_GUARDIAN
    occupation VARCHAR(100),
    phone_primary VARCHAR(30) NOT NULL,
    phone_secondary VARCHAR(30),
    email VARCHAR(255),
    annual_income DECIMAL(14, 2),
    address TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE student_guardians (
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    guardian_id UUID NOT NULL REFERENCES guardians(id) ON DELETE CASCADE,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    can_pickup BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (student_id, guardian_id)
);

CREATE TABLE student_enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    academic_year_id UUID NOT NULL REFERENCES academic_years(id) ON DELETE CASCADE,
    section_id UUID NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
    roll_number VARCHAR(50) NOT NULL,
    enrollment_date DATE NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_year_student UNIQUE (academic_year_id, student_id),
    CONSTRAINT uq_section_roll UNIQUE (section_id, academic_year_id, roll_number)
);

CREATE TABLE student_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    document_title VARCHAR(150) NOT NULL,
    document_type VARCHAR(100) NOT NULL, -- BIRTH_CERTIFICATE, PREV_TRANSCRIPT, MEDICAL_FORM, etc.
    file_path VARCHAR(500) NOT NULL,
    file_size_bytes BIGINT,
    mime_type VARCHAR(100),
    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 6. ATTENDANCE SYSTEM
-- -----------------------------------------------------------------------------
CREATE TABLE student_attendance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    section_id UUID NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
    academic_year_id UUID NOT NULL REFERENCES academic_years(id) ON DELETE CASCADE,
    attendance_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL, -- PRESENT, ABSENT, LATE, HALF_DAY, EXCUSED
    remarks VARCHAR(255),
    marked_by_staff_id UUID REFERENCES staff(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_student_daily_attendance UNIQUE (student_id, attendance_date)
);

CREATE TABLE staff_attendance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
    attendance_date DATE NOT NULL,
    check_in_time TIME,
    check_out_time TIME,
    status VARCHAR(20) NOT NULL, -- PRESENT, ABSENT, LATE, ON_LEAVE
    remarks VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_staff_daily_attendance UNIQUE (staff_id, attendance_date)
);

-- -----------------------------------------------------------------------------
-- 7. EXAMINATIONS & GRADING
-- -----------------------------------------------------------------------------
CREATE TABLE grade_scales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL, -- e.g. 'Standard 100-Point Scale'
    min_percentage DECIMAL(5, 2) NOT NULL,
    max_percentage DECIMAL(5, 2) NOT NULL,
    grade_point DECIMAL(4, 2) NOT NULL,
    grade_name VARCHAR(10) NOT NULL, -- A+, A, B, etc.
    remarks VARCHAR(100)
);

CREATE TABLE exams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    academic_year_id UUID NOT NULL REFERENCES academic_years(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL, -- e.g. 'Term 1 Midterm Examination 2025'
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_published BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE exam_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_id UUID NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    exam_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    max_theory_marks DECIMAL(5, 2) NOT NULL DEFAULT 100.00,
    max_practical_marks DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    pass_marks DECIMAL(5, 2) NOT NULL DEFAULT 33.00,
    room_number VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_exam_class_subject UNIQUE (exam_id, class_id, subject_id)
);

CREATE TABLE exam_marks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_schedule_id UUID NOT NULL REFERENCES exam_schedules(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    theory_marks_obtained DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    practical_marks_obtained DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    is_absent BOOLEAN NOT NULL DEFAULT FALSE,
    remarks VARCHAR(255),
    entered_by_staff_id UUID REFERENCES staff(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_exam_student_marks UNIQUE (exam_schedule_id, student_id)
);

-- -----------------------------------------------------------------------------
-- 8. FEE MANAGEMENT & FINANCIAL LEDGER
-- -----------------------------------------------------------------------------
CREATE TABLE fee_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE, -- Tuition, Transport, Lab, Library, Admission
    description VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE fee_structures (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    academic_year_id UUID NOT NULL REFERENCES academic_years(id) ON DELETE CASCADE,
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    fee_category_id UUID NOT NULL REFERENCES fee_categories(id) ON DELETE CASCADE,
    amount DECIMAL(12, 2) NOT NULL,
    frequency VARCHAR(50) NOT NULL DEFAULT 'MONTHLY', -- ONE_TIME, MONTHLY, QUARTERLY, ANNUAL
    due_day_of_month INT DEFAULT 10,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_fee_structure UNIQUE (academic_year_id, class_id, fee_category_id)
);

CREATE TABLE fee_discounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE, -- Sibling 20%, Staff Child 50%, Merit 100%
    discount_type VARCHAR(20) NOT NULL DEFAULT 'PERCENTAGE', -- PERCENTAGE, FIXED_AMOUNT
    value DECIMAL(12, 2) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE fee_invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_number VARCHAR(100) NOT NULL UNIQUE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    academic_year_id UUID NOT NULL REFERENCES academic_years(id) ON DELETE CASCADE,
    fee_category_id UUID NOT NULL REFERENCES fee_categories(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    amount_due DECIMAL(12, 2) NOT NULL,
    amount_discount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    amount_fine DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    amount_paid DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    balance_amount DECIMAL(12, 2) NOT NULL,
    due_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'UNPAID', -- UNPAID, PARTIAL, PAID, OVERDUE, WAIVED
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE fee_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    receipt_number VARCHAR(100) NOT NULL UNIQUE,
    invoice_id UUID NOT NULL REFERENCES fee_invoices(id) ON DELETE CASCADE,
    amount DECIMAL(12, 2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_mode VARCHAR(50) NOT NULL, -- CASH, CARD, BANK_TRANSFER, CHEQUE, ONLINE
    reference_number VARCHAR(100),
    collected_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    expense_category VARCHAR(100) NOT NULL, -- UTILITIES, MAINTENANCE, SUPPLIES, EVENTS, OTHER
    title VARCHAR(200) NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    expense_date DATE NOT NULL,
    paid_to VARCHAR(150),
    payment_mode VARCHAR(50) NOT NULL,
    receipt_file_path VARCHAR(500),
    approved_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 9. LIBRARY, TRANSPORT & ANCILLARY
-- -----------------------------------------------------------------------------
CREATE TABLE book_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    section_code VARCHAR(50)
);

CREATE TABLE books (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES book_categories(id) ON DELETE SET NULL,
    isbn VARCHAR(50) UNIQUE,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(150) NOT NULL,
    publisher VARCHAR(150),
    edition VARCHAR(50),
    total_copies INT NOT NULL DEFAULT 1,
    available_copies INT NOT NULL DEFAULT 1,
    rack_number VARCHAR(50),
    barcode VARCHAR(100) UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_copies CHECK (available_copies <= total_copies AND available_copies >= 0)
);

CREATE TABLE book_issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id UUID NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    student_id UUID REFERENCES students(id) ON DELETE SET NULL,
    staff_id UUID REFERENCES staff(id) ON DELETE SET NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    fine_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(50) NOT NULL DEFAULT 'ISSUED', -- ISSUED, RETURNED, OVERDUE, LOST
    issued_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_borrower CHECK ((student_id IS NOT NULL AND staff_id IS NULL) OR (student_id IS NULL AND staff_id IS NOT NULL))
);

CREATE TABLE transport_routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    route_name VARCHAR(150) NOT NULL UNIQUE,
    start_point VARCHAR(150) NOT NULL,
    end_point VARCHAR(150) NOT NULL,
    monthly_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    registration_number VARCHAR(50) NOT NULL UNIQUE,
    model VARCHAR(100),
    seating_capacity INT NOT NULL,
    route_id UUID REFERENCES transport_routes(id) ON DELETE SET NULL,
    fitness_certificate_expiry DATE,
    insurance_expiry DATE,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE'
);

CREATE TABLE drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(150) NOT NULL,
    license_number VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(30) NOT NULL,
    vehicle_id UUID UNIQUE REFERENCES vehicles(id) ON DELETE SET NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE'
);

CREATE TABLE student_transport (
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    route_id UUID NOT NULL REFERENCES transport_routes(id) ON DELETE CASCADE,
    stop_name VARCHAR(150) NOT NULL,
    academic_year_id UUID NOT NULL REFERENCES academic_years(id) ON DELETE CASCADE,
    PRIMARY KEY (student_id, academic_year_id)
);

-- -----------------------------------------------------------------------------
-- 10. INDEXING & PERFORMANCE TUNING
-- -----------------------------------------------------------------------------
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_students_admission_number ON students(admission_number);
CREATE INDEX idx_students_name ON students(first_name, last_name);
CREATE INDEX idx_student_enrollments_year ON student_enrollments(academic_year_id, section_id);
CREATE INDEX idx_student_attendance_date ON student_attendance(attendance_date, section_id);
CREATE INDEX idx_exam_marks_schedule ON exam_marks(exam_schedule_id);
CREATE INDEX idx_fee_invoices_student ON fee_invoices(student_id, status);
CREATE INDEX idx_fee_invoices_due ON fee_invoices(due_date);
CREATE INDEX idx_audit_logs_user_date ON audit_logs(user_id, created_at DESC);
CREATE INDEX idx_book_issues_status ON book_issues(status, due_date);
