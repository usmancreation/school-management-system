-- =============================================================================
-- V4__seed_all_roles_users.sql
-- Seed default login accounts for all 11 ERP User Roles
-- Password for all accounts: Admin@123
-- =============================================================================

DO $$
DECLARE
    pwd_hash VARCHAR(255) := '$2a$12$8x1sD7fGvV6.z9K9d2K0.OOm9t3hG.oJ1fG1iU6gN7k0m7k0m7k0m';
    u_id UUID;
    r_id UUID;
BEGIN
    -- 1. Super Admin
    SELECT id INTO r_id FROM roles WHERE name = 'ROLE_SUPER_ADMIN';
    INSERT INTO users (username, email, password_hash, full_name, is_active)
    VALUES ('superadmin', 'superadmin@oakridgeacademy.edu', pwd_hash, 'Chief System Administrator', TRUE)
    ON CONFLICT (username) DO UPDATE SET password_hash = EXCLUDED.password_hash
    RETURNING id INTO u_id;
    INSERT INTO user_roles (user_id, role_id) VALUES (u_id, r_id) ON CONFLICT DO NOTHING;

    -- 2. Admin
    SELECT id INTO r_id FROM roles WHERE name = 'ROLE_ADMIN';
    INSERT INTO users (username, email, password_hash, full_name, is_active)
    VALUES ('admin', 'admin@oakridgeacademy.edu', pwd_hash, 'Campus Administrator', TRUE)
    ON CONFLICT (username) DO NOTHING
    RETURNING id INTO u_id;
    IF u_id IS NOT NULL THEN INSERT INTO user_roles (user_id, role_id) VALUES (u_id, r_id) ON CONFLICT DO NOTHING; END IF;

    -- 3. Principal
    SELECT id INTO r_id FROM roles WHERE name = 'ROLE_PRINCIPAL';
    INSERT INTO users (username, email, password_hash, full_name, is_active)
    VALUES ('principal', 'principal@oakridgeacademy.edu', pwd_hash, 'Dr. Arthur Pendelton (Principal)', TRUE)
    ON CONFLICT (username) DO NOTHING
    RETURNING id INTO u_id;
    IF u_id IS NOT NULL THEN INSERT INTO user_roles (user_id, role_id) VALUES (u_id, r_id) ON CONFLICT DO NOTHING; END IF;

    -- 4. Vice Principal
    SELECT id INTO r_id FROM roles WHERE name = 'ROLE_VICE_PRINCIPAL';
    INSERT INTO users (username, email, password_hash, full_name, is_active)
    VALUES ('viceprincipal', 'viceprincipal@oakridgeacademy.edu', pwd_hash, 'Margaret Vance (Vice Principal)', TRUE)
    ON CONFLICT (username) DO NOTHING
    RETURNING id INTO u_id;
    IF u_id IS NOT NULL THEN INSERT INTO user_roles (user_id, role_id) VALUES (u_id, r_id) ON CONFLICT DO NOTHING; END IF;

    -- 5. Teacher
    SELECT id INTO r_id FROM roles WHERE name = 'ROLE_TEACHER';
    INSERT INTO users (username, email, password_hash, full_name, is_active)
    VALUES ('teacher', 'teacher@oakridgeacademy.edu', pwd_hash, 'Sarah Connor (Senior Teacher)', TRUE)
    ON CONFLICT (username) DO NOTHING
    RETURNING id INTO u_id;
    IF u_id IS NOT NULL THEN INSERT INTO user_roles (user_id, role_id) VALUES (u_id, r_id) ON CONFLICT DO NOTHING; END IF;

    -- 6. Accountant
    SELECT id INTO r_id FROM roles WHERE name = 'ROLE_ACCOUNTANT';
    INSERT INTO users (username, email, password_hash, full_name, is_active)
    VALUES ('accountant', 'accountant@oakridgeacademy.edu', pwd_hash, 'Marcus Sterling (Chief Accountant)', TRUE)
    ON CONFLICT (username) DO NOTHING
    RETURNING id INTO u_id;
    IF u_id IS NOT NULL THEN INSERT INTO user_roles (user_id, role_id) VALUES (u_id, r_id) ON CONFLICT DO NOTHING; END IF;

    -- 7. Receptionist
    SELECT id INTO r_id FROM roles WHERE name = 'ROLE_RECEPTIONIST';
    INSERT INTO users (username, email, password_hash, full_name, is_active)
    VALUES ('receptionist', 'receptionist@oakridgeacademy.edu', pwd_hash, 'Clara Oswald (Front Desk Receptionist)', TRUE)
    ON CONFLICT (username) DO NOTHING
    RETURNING id INTO u_id;
    IF u_id IS NOT NULL THEN INSERT INTO user_roles (user_id, role_id) VALUES (u_id, r_id) ON CONFLICT DO NOTHING; END IF;

    -- 8. Student
    SELECT id INTO r_id FROM roles WHERE name = 'ROLE_STUDENT';
    INSERT INTO users (username, email, password_hash, full_name, is_active)
    VALUES ('student', 'student@oakridgeacademy.edu', pwd_hash, 'Alexander Wright (Grade 10 Student)', TRUE)
    ON CONFLICT (username) DO NOTHING
    RETURNING id INTO u_id;
    IF u_id IS NOT NULL THEN INSERT INTO user_roles (user_id, role_id) VALUES (u_id, r_id) ON CONFLICT DO NOTHING; END IF;

    -- 9. Parent
    SELECT id INTO r_id FROM roles WHERE name = 'ROLE_PARENT';
    INSERT INTO users (username, email, password_hash, full_name, is_active)
    VALUES ('parent', 'parent@oakridgeacademy.edu', pwd_hash, 'David Wright (Guardian / Parent)', TRUE)
    ON CONFLICT (username) DO NOTHING
    RETURNING id INTO u_id;
    IF u_id IS NOT NULL THEN INSERT INTO user_roles (user_id, role_id) VALUES (u_id, r_id) ON CONFLICT DO NOTHING; END IF;

    -- 10. Library Staff
    SELECT id INTO r_id FROM roles WHERE name = 'ROLE_LIBRARY_STAFF';
    INSERT INTO users (username, email, password_hash, full_name, is_active)
    VALUES ('librarian', 'librarian@oakridgeacademy.edu', pwd_hash, 'Evelyn Reed (Head Librarian)', TRUE)
    ON CONFLICT (username) DO NOTHING
    RETURNING id INTO u_id;
    IF u_id IS NOT NULL THEN INSERT INTO user_roles (user_id, role_id) VALUES (u_id, r_id) ON CONFLICT DO NOTHING; END IF;

    -- 11. Transport Manager
    SELECT id INTO r_id FROM roles WHERE name = 'ROLE_TRANSPORT_MANAGER';
    INSERT INTO users (username, email, password_hash, full_name, is_active)
    VALUES ('transport', 'transport@oakridgeacademy.edu', pwd_hash, 'Thomas Miller (Transport Fleet Manager)', TRUE)
    ON CONFLICT (username) DO NOTHING
    RETURNING id INTO u_id;
    IF u_id IS NOT NULL THEN INSERT INTO user_roles (user_id, role_id) VALUES (u_id, r_id) ON CONFLICT DO NOTHING; END IF;

END $$;
