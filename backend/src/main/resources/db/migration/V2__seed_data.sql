-- =============================================================================
-- Enterprise School Management ERP - PostgreSQL Seed Data
-- Migration: V2__seed_data.sql
-- =============================================================================

-- 1. SCHOOL PROFILE
INSERT INTO school_profile (
    id, school_name, affiliation_code, registration_number, email, phone_primary,
    address_line1, city, state, postal_code, country, currency_code, currency_symbol
) VALUES (
    'a0000000-0000-0000-0000-000000000001',
    'Oakridge International Academy',
    'AFF-CBSE-9982',
    'REG-2025-001',
    'admin@oakridgeacademy.edu',
    '+1 (555) 234-5678',
    '4500 University Avenue, Academic Hills',
    'Metropolis',
    'NY',
    '10001',
    'United States',
    'USD',
    '$'
);

-- 2. ACADEMIC YEAR
INSERT INTO academic_years (id, name, start_date, end_date, is_current, is_locked)
VALUES ('a1000000-0000-0000-0000-000000000001', '2025-2026', '2025-08-01', '2026-06-30', TRUE, FALSE);

-- 3. PERMISSIONS
INSERT INTO permissions (id, name, module, description) VALUES
('b0000000-0000-0000-0000-000000000001', 'STUDENT_READ', 'STUDENT', 'View student roster and profiles'),
('b0000000-0000-0000-0000-000000000002', 'STUDENT_CREATE', 'STUDENT', 'Admit new students'),
('b0000000-0000-0000-0000-000000000003', 'STUDENT_UPDATE', 'STUDENT', 'Update student details and promotions'),
('b0000000-0000-0000-0000-000000000004', 'STUDENT_DELETE', 'STUDENT', 'Delete or archive student records'),

('b0000000-0000-0000-0000-000000000005', 'FEE_VIEW', 'FEE', 'View fee structures and balances'),
('b0000000-0000-0000-0000-000000000006', 'FEE_COLLECT', 'FEE', 'Collect fees and issue receipts'),
('b0000000-0000-0000-0000-000000000007', 'FEE_DISCOUNT', 'FEE', 'Apply discounts and waivers'),

('b0000000-0000-0000-0000-000000000008', 'ATTENDANCE_MARK', 'ATTENDANCE', 'Take daily attendance'),
('b0000000-0000-0000-0000-000000000009', 'ATTENDANCE_VIEW', 'ATTENDANCE', 'View attendance analytics'),

('b0000000-0000-0000-0000-000000000010', 'EXAM_MANAGE', 'EXAM', 'Schedule exams and create grade scales'),
('b0000000-0000-0000-0000-000000000011', 'MARKS_ENTRY', 'EXAM', 'Input and submit student marks'),
('b0000000-0000-0000-0000-000000000012', 'REPORT_CARD_PUBLISH', 'EXAM', 'Generate and publish official report cards'),

('b0000000-0000-0000-0000-000000000013', 'SYSTEM_ADMIN', 'SYSTEM', 'Full system configurations, roles, backups');

-- 4. ROLES
INSERT INTO roles (id, name, description, is_system_role) VALUES
('c0000000-0000-0000-0000-000000000001', 'ROLE_SUPER_ADMIN', 'Full unrestricted platform access', TRUE),
('c0000000-0000-0000-0000-000000000002', 'ROLE_ADMIN', 'School campus administration', TRUE),
('c0000000-0000-0000-0000-000000000003', 'ROLE_PRINCIPAL', 'Executive academic management', TRUE),
('c0000000-0000-0000-0000-000000000004', 'ROLE_VICE_PRINCIPAL', 'Curriculum and faculty supervision', TRUE),
('c0000000-0000-0000-0000-000000000005', 'ROLE_TEACHER', 'Classroom educator', TRUE),
('c0000000-0000-0000-0000-000000000006', 'ROLE_ACCOUNTANT', 'Bursary and financial collection', TRUE),
('c0000000-0000-0000-0000-000000000007', 'ROLE_RECEPTIONIST', 'Front desk, inquiries, certificates', TRUE),
('c0000000-0000-0000-0000-000000000008', 'ROLE_STUDENT', 'Enrolled student self-service', TRUE),
('c0000000-0000-0000-0000-000000000009', 'ROLE_PARENT', 'Guardian access portal', TRUE),
('c0000000-0000-0000-0000-000000000010', 'ROLE_LIBRARY_STAFF', 'Catalog & circulation management', TRUE),
('c0000000-0000-0000-0000-000000000011', 'ROLE_TRANSPORT_MANAGER', 'Fleet logistics and route management', TRUE);

-- Map all permissions to ROLE_SUPER_ADMIN
INSERT INTO role_permissions (role_id, permission_id)
SELECT 'c0000000-0000-0000-0000-000000000001', id FROM permissions;

-- 5. DEFAULT SUPER ADMIN USER (Password: Admin@123)
-- BCrypt cost 12 hash: $2a$12$e8hZfM.w7Mszl8GzD0X1yOMM3U92K3bUaZl1kK0KzD4sYvT9jTq2K
INSERT INTO users (
    id, username, email, password_hash, full_name, phone, is_active, is_locked
) VALUES (
    'd0000000-0000-0000-0000-000000000001',
    'superadmin',
    'superadmin@oakridgeacademy.edu',
    '$2a$12$8x1sD7fGvV6.z9K9d2K0.OOm9t3hG.oJ1fG1iU6gN7k0m7k0m7k0m', -- Standard BCrypt placeholder for dev
    'Chief System Administrator',
    '+1 555-0199',
    TRUE,
    FALSE
);

INSERT INTO user_roles (user_id, role_id)
VALUES ('d0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001');

-- 6. GRADE SCALES
INSERT INTO grade_scales (name, min_percentage, max_percentage, grade_point, grade_name, remarks) VALUES
('Standard 4.0 Scale', 90.00, 100.00, 4.00, 'A+', 'Outstanding'),
('Standard 4.0 Scale', 80.00, 89.99, 3.70, 'A', 'Excellent'),
('Standard 4.0 Scale', 70.00, 79.99, 3.00, 'B', 'Good'),
('Standard 4.0 Scale', 60.00, 69.99, 2.00, 'C', 'Satisfactory'),
('Standard 4.0 Scale', 50.00, 59.99, 1.00, 'D', 'Pass'),
('Standard 4.0 Scale', 0.00, 49.99, 0.00, 'F', 'Fail');

-- 7. FEE CATEGORIES
INSERT INTO fee_categories (name, description) VALUES
('Tuition Fee', 'Core curriculum and instructional cost'),
('Admission Fee', 'One-time registration and enrolment processing'),
('Laboratory Fee', 'Science and computing laboratory maintenance'),
('Transportation Fee', 'Bus fleet operation and fuel surcharge'),
('Library Fee', 'Resource acquisition and digital journals subscription');

-- 8. DEFAULT ACADEMIC CLASSES
INSERT INTO classes (name, numeric_order, description) VALUES
('Grade 1', 1, 'Primary School First Grade'),
('Grade 2', 2, 'Primary School Second Grade'),
('Grade 3', 3, 'Primary School Third Grade'),
('Grade 4', 4, 'Primary School Fourth Grade'),
('Grade 5', 5, 'Primary School Fifth Grade'),
('Grade 6', 6, 'Middle School Sixth Grade'),
('Grade 7', 7, 'Middle School Seventh Grade'),
('Grade 8', 8, 'Middle School Eighth Grade'),
('Grade 9', 9, 'High School Freshman'),
('Grade 10', 10, 'High School Sophomore'),
('Grade 11', 11, 'High School Junior'),
('Grade 12', 12, 'High School Senior');
