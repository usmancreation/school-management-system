-- =============================================================================
-- V3__realistic_demo_records.sql
-- Seed realistic classes, sections, subjects, teachers, students, invoices, exams
-- =============================================================================

-- Sections for Grades
DO $$
DECLARE
    g10_id UUID;
    sec_a_id UUID;
    sec_b_id UUID;
    math_id UUID;
    eng_id UUID;
    sci_id UUID;
    hist_id UUID;
    curr_year_id UUID;
    staff1_id UUID;
    staff2_id UUID;
    u_teacher1 UUID := gen_random_uuid();
    u_teacher2 UUID := gen_random_uuid();
    st1_id UUID := gen_random_uuid();
    st2_id UUID := gen_random_uuid();
    st3_id UUID := gen_random_uuid();
    st4_id UUID := gen_random_uuid();
    st5_id UUID := gen_random_uuid();
    fee_cat_tuition UUID;
    fee_cat_trans UUID;
    exam_mid_id UUID := gen_random_uuid();
    sched_math UUID := gen_random_uuid();
    sched_sci UUID := gen_random_uuid();
BEGIN
    SELECT id INTO curr_year_id FROM academic_years WHERE is_current = TRUE LIMIT 1;
    SELECT id INTO g10_id FROM classes WHERE name = 'Grade 10' LIMIT 1;
    SELECT id INTO fee_cat_tuition FROM fee_categories WHERE name = 'Tuition Fee' LIMIT 1;
    SELECT id INTO fee_cat_trans FROM fee_categories WHERE name = 'Transportation Fee' LIMIT 1;

    -- Create Sections
    INSERT INTO sections (id, class_id, name, room_number, capacity)
    VALUES (gen_random_uuid(), g10_id, 'A', 'Room 301', 35)
    RETURNING id INTO sec_a_id;

    INSERT INTO sections (id, class_id, name, room_number, capacity)
    VALUES (gen_random_uuid(), g10_id, 'B', 'Room 302', 35)
    RETURNING id INTO sec_b_id;

    -- Create Subjects
    INSERT INTO subjects (id, name, code, type, pass_marks, total_marks)
    VALUES (gen_random_uuid(), 'Mathematics', 'MATH-10', 'THEORY', 35.0, 100.0)
    RETURNING id INTO math_id;

    INSERT INTO subjects (id, name, code, type, pass_marks, total_marks)
    VALUES (gen_random_uuid(), 'Physics & Chemistry', 'SCI-10', 'BOTH', 35.0, 100.0)
    RETURNING id INTO sci_id;

    INSERT INTO subjects (id, name, code, type, pass_marks, total_marks)
    VALUES (gen_random_uuid(), 'English Literature', 'ENG-10', 'THEORY', 35.0, 100.0)
    RETURNING id INTO eng_id;

    INSERT INTO subjects (id, name, code, type, pass_marks, total_marks)
    VALUES (gen_random_uuid(), 'World History', 'HIST-10', 'THEORY', 35.0, 100.0)
    RETURNING id INTO hist_id;

    INSERT INTO class_subjects (class_id, subject_id) VALUES
    (g10_id, math_id), (g10_id, sci_id), (g10_id, eng_id), (g10_id, hist_id);

    -- Create Teachers (Staff)
    INSERT INTO users (id, username, email, password_hash, full_name, phone)
    VALUES (u_teacher1, 'sarah.connor', 'sarah.c@school.edu', '$2a$12$8x1sD7fGvV6.z9K9d2K0.OOm9t3hG.oJ1fG1iU6gN7k0m7k0m7k0m', 'Sarah Connor', '+1 555-0144');
    INSERT INTO user_roles (user_id, role_id) VALUES (u_teacher1, (SELECT id FROM roles WHERE name = 'ROLE_TEACHER'));

    INSERT INTO staff (id, user_id, employee_code, first_name, last_name, gender, date_of_birth, date_of_joining, designation, basic_salary)
    VALUES (gen_random_uuid(), u_teacher1, 'EMP-1001', 'Sarah', 'Connor', 'FEMALE', '1985-05-12', '2020-08-01', 'Senior Mathematics Teacher', 4800.00)
    RETURNING id INTO staff1_id;

    INSERT INTO users (id, username, email, password_hash, full_name, phone)
    VALUES (u_teacher2, 'robert.langdon', 'robert.l@school.edu', '$2a$12$8x1sD7fGvV6.z9K9d2K0.OOm9t3hG.oJ1fG1iU6gN7k0m7k0m7k0m', 'Dr. Robert Langdon', '+1 555-0155');
    INSERT INTO user_roles (user_id, role_id) VALUES (u_teacher2, (SELECT id FROM roles WHERE name = 'ROLE_TEACHER'));

    INSERT INTO staff (id, user_id, employee_code, first_name, last_name, gender, date_of_birth, date_of_joining, designation, basic_salary)
    VALUES (gen_random_uuid(), u_teacher2, 'EMP-1002', 'Robert', 'Langdon', 'MALE', '1982-11-20', '2019-07-15', 'Science Department Head', 5400.00)
    RETURNING id INTO staff2_id;

    -- Assign Class Teacher
    INSERT INTO section_teachers (section_id, staff_id, is_class_teacher, academic_year_id)
    VALUES (sec_a_id, staff1_id, TRUE, curr_year_id);

    -- Create 5 Students
    INSERT INTO students (id, admission_number, admission_date, first_name, last_name, gender, date_of_birth, blood_group, nationality, email, phone, current_address) VALUES
    (st1_id, 'SCH-2025-001', '2025-08-05', 'Alexander', 'Wright', 'MALE', '2010-03-15', 'O+', 'American', 'alex.w@student.edu', '+1 555-1001', '742 Evergreen Terrace, Springfield'),
    (st2_id, 'SCH-2025-002', '2025-08-05', 'Emma', 'Watson', 'FEMALE', '2010-06-22', 'A+', 'American', 'emma.w@student.edu', '+1 555-1002', '12 Grimmauld Place, Metropolis'),
    (st3_id, 'SCH-2025-003', '2025-08-06', 'Lucas', 'Silva', 'MALE', '2010-01-18', 'B+', 'Brazilian', 'lucas.s@student.edu', '+1 555-1003', '88 Riverside Dr, Metropolis'),
    (st4_id, 'SCH-2025-004', '2025-08-06', 'Sophia', 'Chen', 'FEMALE', '2010-09-30', 'AB+', 'American', 'sophia.c@student.edu', '+1 555-1004', '150 West End Ave, Metropolis'),
    (st5_id, 'SCH-2025-005', '2025-08-07', 'Liam', 'Johnson', 'MALE', '2010-04-12', 'O-', 'American', 'liam.j@student.edu', '+1 555-1005', '42 Wallaby Way, Metropolis');

    -- Enroll Students into Grade 10-A
    INSERT INTO student_enrollments (student_id, academic_year_id, section_id, roll_number, enrollment_date) VALUES
    (st1_id, curr_year_id, sec_a_id, '10A-01', '2025-08-05'),
    (st2_id, curr_year_id, sec_a_id, '10A-02', '2025-08-05'),
    (st3_id, curr_year_id, sec_a_id, '10A-03', '2025-08-06'),
    (st4_id, curr_year_id, sec_a_id, '10A-04', '2025-08-06'),
    (st5_id, curr_year_id, sec_a_id, '10A-05', '2025-08-07');

    -- Invoices for Tuition
    INSERT INTO fee_invoices (invoice_number, student_id, academic_year_id, fee_category_id, title, amount_due, amount_paid, balance_amount, due_date, status) VALUES
    ('INV-2025-0001', st1_id, curr_year_id, fee_cat_tuition, 'September 2025 Tuition Fee', 450.00, 450.00, 0.00, '2025-09-10', 'PAID'),
    ('INV-2025-0002', st2_id, curr_year_id, fee_cat_tuition, 'September 2025 Tuition Fee', 450.00, 200.00, 250.00, '2025-09-10', 'PARTIAL'),
    ('INV-2025-0003', st3_id, curr_year_id, fee_cat_tuition, 'September 2025 Tuition Fee', 450.00, 0.00, 450.00, '2025-09-10', 'UNPAID'),
    ('INV-2025-0004', st4_id, curr_year_id, fee_cat_tuition, 'September 2025 Tuition Fee', 450.00, 450.00, 0.00, '2025-09-10', 'PAID'),
    ('INV-2025-0005', st5_id, curr_year_id, fee_cat_tuition, 'September 2025 Tuition Fee', 450.00, 0.00, 450.00, '2025-09-10', 'OVERDUE');

    -- Attendance for Today
    INSERT INTO student_attendance (student_id, section_id, academic_year_id, attendance_date, status, marked_by_staff_id) VALUES
    (st1_id, sec_a_id, curr_year_id, CURRENT_DATE, 'PRESENT', staff1_id),
    (st2_id, sec_a_id, curr_year_id, CURRENT_DATE, 'PRESENT', staff1_id),
    (st3_id, sec_a_id, curr_year_id, CURRENT_DATE, 'ABSENT', staff1_id),
    (st4_id, sec_a_id, curr_year_id, CURRENT_DATE, 'PRESENT', staff1_id),
    (st5_id, sec_a_id, curr_year_id, CURRENT_DATE, 'LATE', staff1_id);

    -- Create Mid-Term Exam
    INSERT INTO exams (id, academic_year_id, name, start_date, end_date, is_published)
    VALUES (exam_mid_id, curr_year_id, 'Mid-Term Examination 2025', '2025-10-10', '2025-10-25', TRUE);

    INSERT INTO exam_schedules (id, exam_id, class_id, subject_id, exam_date, start_time, end_time, max_theory_marks, max_practical_marks, pass_marks) VALUES
    (sched_math, exam_mid_id, g10_id, math_id, '2025-10-12', '09:00', '12:00', 80.00, 20.00, 35.00),
    (sched_sci, exam_mid_id, g10_id, sci_id, '2025-10-14', '09:00', '12:00', 70.00, 30.00, 35.00);

    -- Marks
    INSERT INTO exam_marks (exam_schedule_id, student_id, theory_marks_obtained, practical_marks_obtained, entered_by_staff_id) VALUES
    (sched_math, st1_id, 76.00, 19.00, staff1_id),
    (sched_math, st2_id, 79.00, 20.00, staff1_id),
    (sched_math, st3_id, 62.00, 16.00, staff1_id),
    (sched_math, st4_id, 78.00, 19.50, staff1_id),
    (sched_math, st5_id, 55.00, 14.00, staff1_id);

    -- Books in Library
    INSERT INTO book_categories (name, section_code) VALUES ('Science & Tech', 'SCI-01'), ('Mathematics', 'MTH-01'), ('Literature', 'LIT-01');
    INSERT INTO books (isbn, title, author, publisher, total_copies, available_copies, barcode) VALUES
    ('978-0131103627', 'The C Programming Language', 'Brian W. Kernighan', 'Prentice Hall', 5, 4, 'BK-10001'),
    ('978-0321751041', 'The Art of Computer Programming', 'Donald E. Knuth', 'Addison-Wesley', 3, 3, 'BK-10002'),
    ('978-0199535569', 'Pride and Prejudice', 'Jane Austen', 'Oxford World Classics', 10, 8, 'BK-10003');

    -- Transport Routes
    INSERT INTO transport_routes (route_name, start_point, end_point, monthly_fee) VALUES
    ('Route 1 - North Metro Express', 'North Terminal', 'School Main Gate', 65.00),
    ('Route 2 - Downtown City Loop', 'Central Station', 'School Main Gate', 80.00);

END $$;
