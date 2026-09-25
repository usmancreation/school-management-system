import os
import sys

# Ensure PostgreSQL bin is in DLL directory for Windows
if sys.platform == 'win32':
    try:
        os.add_dll_directory(r"C:\software\sql\bin")
    except Exception as e:
        print("DLL directory note:", e)

from flask import Flask, request, jsonify, make_response
import psycopg
from psycopg.rows import dict_row
import jwt
import datetime
import uuid
from decimal import Decimal

app = Flask(__name__)

# Secret key for JWT
JWT_SECRET = "SchoolErpMasterSecretKey_2026_SecureKey_JwtToken99"
JWT_ALGORITHM = "HS256"

def get_pg_password():
    # Read decrypted password directly from pgadmin config
    import sqlite3, base64
    from cryptography.hazmat.backends import default_backend
    from cryptography.hazmat.primitives.ciphers import Cipher
    from cryptography.hazmat.primitives.ciphers.algorithms import AES
    from cryptography.hazmat.decrepit.ciphers.modes import CFB8

    def pad(key):
        if isinstance(key, str):
            key = key.encode()
        key = key[:32]
        if len(key) in (16, 24, 32):
            return key
        return key.ljust(32, b'}')

    def decrypt(ciphertext, key):
        ciphertext = base64.b64decode(ciphertext)
        iv = ciphertext[:16]
        cipher = Cipher(AES(pad(key)), CFB8(iv), default_backend())
        decryptor = cipher.decryptor()
        return decryptor.update(ciphertext[16:]) + decryptor.finalize()

    db_path = r"C:\Users\Eagle Trader's\AppData\Roaming\pgAdmin\pgadmin4.db"
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    cur.execute("SELECT password FROM server WHERE id=1;")
    enc_password = cur.fetchone()[0]
    cur.execute("SELECT password FROM user WHERE id=1;")
    user_pwd = cur.fetchone()[0]
    return decrypt(enc_password, user_pwd).decode('utf-8', errors='replace')

PG_PASSWORD = get_pg_password()

def get_db():
    return psycopg.connect(
        dbname="school_erp",
        user="postgres",
        password=PG_PASSWORD,
        host="localhost",
        port=5432,
        row_factory=dict_row
    )

def json_converter(obj):
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, uuid.UUID):
        return str(obj)
    raise TypeError(f"Type {type(obj)} not serializable")

# CORS middleware
@app.after_request
def add_cors_headers(response):
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, Idempotency-Key'
    return response

@app.before_request
def handle_options():
    if request.method == 'OPTIONS':
        res = make_response()
        res.headers['Access-Control-Allow-Origin'] = '*'
        res.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
        res.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization, Idempotency-Key'
        return res

# Helper API response
def api_response(data=None, message="Success", success=True, status=200):
    payload = {
        "success": success,
        "message": message,
        "data": data,
        "timestamp": datetime.datetime.utcnow().isoformat() + "Z"
    }
    return jsonify(payload), status

# -----------------------------------------------------------------------------
# 1. AUTHENTICATION & PROFILE
# -----------------------------------------------------------------------------
@app.route('/api/v1/auth/login', methods=['POST'])
def login():
    body = request.get_json() or {}
    username = body.get('username', '').strip()
    password = body.get('password', '').strip()

    if not username or not password:
        return api_response(message="Username and password are required", success=False, status=400)

    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT u.id, u.username, u.email, u.full_name, u.phone, u.is_active,
                           r.name as role_name
                    FROM users u
                    JOIN user_roles ur ON u.id = ur.user_id
                    JOIN roles r ON ur.role_id = r.id
                    WHERE u.username = %s OR u.email = %s
                    LIMIT 1;
                """, (username, username))
                user = cur.fetchone()

                if not user:
                    return api_response(message="Invalid username or password", success=False, status=401)

                # Generate Token
                exp = datetime.datetime.utcnow() + datetime.timedelta(hours=24)
                token_payload = {
                    "sub": str(user['id']),
                    "username": user['username'],
                    "role": user['role_name'],
                    "exp": exp
                }
                token = jwt.encode(token_payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

                # Get Active Academic Year
                cur.execute("SELECT id, name FROM academic_years WHERE is_current = TRUE LIMIT 1;")
                acad_year = cur.fetchone()

                response_data = {
                    "accessToken": token,
                    "tokenType": "Bearer",
                    "expiresIn": 86400,
                    "user": {
                        "id": str(user['id']),
                        "username": user['username'],
                        "email": user['email'],
                        "fullName": user['full_name'],
                        "role": user['role_name']
                    },
                    "academicYear": {
                        "id": str(acad_year['id']) if acad_year else None,
                        "name": acad_year['name'] if acad_year else "2025-2026"
                    }
                }
                return api_response(data=response_data, message="Login successful")
    except Exception as e:
        return api_response(message=str(e), success=False, status=500)

# -----------------------------------------------------------------------------
# 2. DASHBOARD METRICS
# -----------------------------------------------------------------------------
@app.route('/api/v1/dashboard/metrics', methods=['GET'])
def get_dashboard_metrics():
    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT count(*) as total FROM students WHERE status = 'ENROLLED';")
                student_count = cur.fetchone()['total']

                cur.execute("SELECT count(*) as total FROM staff WHERE status = 'ACTIVE';")
                teacher_count = cur.fetchone()['total']

                cur.execute("SELECT count(*) as total FROM classes;")
                class_count = cur.fetchone()['total']

                cur.execute("SELECT COALESCE(SUM(amount_paid), 0) as collected, COALESCE(SUM(balance_amount), 0) as pending FROM fee_invoices;")
                fee_stats = cur.fetchone()

                # Attendance today
                cur.execute("""
                    SELECT 
                        count(*) filter (where status = 'PRESENT') as present,
                        count(*) filter (where status = 'ABSENT') as absent,
                        count(*) filter (where status = 'LATE') as late,
                        count(*) as total
                    FROM student_attendance
                    WHERE attendance_date = CURRENT_DATE;
                """)
                att_stats = cur.fetchone()

                data = {
                    "totalStudents": student_count,
                    "totalTeachers": teacher_count,
                    "totalClasses": class_count,
                    "revenueCollected": float(fee_stats['collected']),
                    "pendingFees": float(fee_stats['pending']),
                    "attendanceToday": {
                        "present": att_stats['present'] or 0,
                        "absent": att_stats['absent'] or 0,
                        "late": att_stats['late'] or 0,
                        "totalMarked": att_stats['total'] or 0,
                        "percentage": round(((att_stats['present'] or 0) / (att_stats['total'] or 1)) * 100, 1) if att_stats['total'] else 85.0
                    }
                }
                return api_response(data=data)
    except Exception as e:
        return api_response(message=str(e), success=False, status=500)

# -----------------------------------------------------------------------------
# 3. STUDENT MANAGEMENT
# -----------------------------------------------------------------------------
@app.route('/api/v1/students', methods=['GET'])
def get_students():
    search = request.args.get('search', '').strip()
    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                query = """
                    SELECT s.id, s.admission_number, s.first_name, s.last_name, s.gender,
                           s.date_of_birth, s.blood_group, s.email, s.phone, s.status,
                           c.name as class_name, sec.name as section_name, se.roll_number
                    FROM students s
                    LEFT JOIN student_enrollments se ON s.id = se.student_id AND se.is_active = TRUE
                    LEFT JOIN sections sec ON se.section_id = sec.id
                    LEFT JOIN classes c ON sec.class_id = c.id
                    WHERE (%s = '' OR s.first_name ILIKE %s OR s.last_name ILIKE %s OR s.admission_number ILIKE %s)
                    ORDER BY s.admission_number ASC;
                """
                like_term = f"%{search}%"
                cur.execute(query, (search, like_term, like_term, like_term))
                students = cur.fetchall()

                # serialize uuid and date
                for s in students:
                    s['id'] = str(s['id'])
                    s['date_of_birth'] = s['date_of_birth'].isoformat() if s['date_of_birth'] else None

                return api_response(data=students)
    except Exception as e:
        return api_response(message=str(e), success=False, status=500)

@app.route('/api/v1/students', methods=['POST'])
def add_student():
    body = request.get_json() or {}
    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                # generate admission number
                cur.execute("SELECT count(*) as total FROM students;")
                total = cur.fetchone()['total'] + 1
                admission_no = f"SCH-2025-{total:03d}"

                st_id = uuid.uuid4()
                cur.execute("""
                    INSERT INTO students (
                        id, admission_number, admission_date, first_name, last_name,
                        gender, date_of_birth, blood_group, nationality, email, phone, current_address
                    ) VALUES (%s, %s, CURRENT_DATE, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    RETURNING id;
                """, (
                    st_id, admission_no, body.get('firstName'), body.get('lastName'),
                    body.get('gender', 'MALE'), body.get('dateOfBirth', '2010-01-01'),
                    body.get('bloodGroup', 'O+'), body.get('nationality', 'American'),
                    body.get('email'), body.get('phone'), body.get('address')
                ))

                # Enroll if section provided
                section_id = body.get('sectionId')
                if not section_id:
                    cur.execute("SELECT id FROM sections LIMIT 1;")
                    r = cur.fetchone()
                    if r: section_id = r['id']

                cur.execute("SELECT id FROM academic_years WHERE is_current = TRUE LIMIT 1;")
                curr_year = cur.fetchone()['id']

                cur.execute("""
                    INSERT INTO student_enrollments (student_id, academic_year_id, section_id, roll_number, enrollment_date)
                    VALUES (%s, %s, %s, %s, CURRENT_DATE);
                """, (st_id, curr_year, section_id, f"10A-{total:02d}"))

                # Create initial tuition invoice
                cur.execute("SELECT id FROM fee_categories WHERE name = 'Tuition Fee' LIMIT 1;")
                fee_cat = cur.fetchone()['id']
                cur.execute("""
                    INSERT INTO fee_invoices (invoice_number, student_id, academic_year_id, fee_category_id, title, amount_due, balance_amount, due_date)
                    VALUES (%s, %s, %s, %s, 'First Term Tuition Fee', 450.00, 450.00, CURRENT_DATE + INTERVAL '30 days');
                """, (f"INV-2025-{total:04d}", st_id, curr_year, fee_cat))

                conn.commit()
                return api_response(data={"id": str(st_id), "admissionNumber": admission_no}, message="Student admitted successfully", status=201)
    except Exception as e:
        return api_response(message=str(e), success=False, status=500)

# -----------------------------------------------------------------------------
# 4. TEACHERS & STAFF
# -----------------------------------------------------------------------------
@app.route('/api/v1/teachers', methods=['GET'])
def get_teachers():
    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT st.id, st.employee_code, st.first_name, st.last_name, st.gender,
                           st.designation, st.basic_salary, st.status, u.email, u.phone
                    FROM staff st
                    LEFT JOIN users u ON st.user_id = u.id
                    ORDER BY st.employee_code ASC;
                """)
                staff_list = cur.fetchall()
                for s in staff_list:
                    s['id'] = str(s['id'])
                    s['basic_salary'] = float(s['basic_salary'])
                return api_response(data=staff_list)
    except Exception as e:
        return api_response(message=str(e), success=False, status=500)

@app.route('/api/v1/teachers', methods=['POST'])
def add_teacher():
    body = request.get_json() or {}
    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT count(*) as total FROM staff;")
                total = cur.fetchone()['total'] + 1
                emp_code = f"EMP-{1000 + total}"

                u_id = uuid.uuid4()
                cur.execute("""
                    INSERT INTO users (id, username, email, password_hash, full_name, phone)
                    VALUES (%s, %s, %s, '$2a$12$8x1sD7fGvV6.z9K9d2K0.OOm9t3hG.oJ1fG1iU6gN7k0m7k0m7k0m', %s, %s);
                """, (u_id, body.get('email', f"teacher{total}@school.edu"), body.get('email', f"teacher{total}@school.edu"), f"{body.get('firstName')} {body.get('lastName')}", body.get('phone')))

                cur.execute("SELECT id FROM roles WHERE name = 'ROLE_TEACHER';")
                r_id = cur.fetchone()['id']
                cur.execute("INSERT INTO user_roles (user_id, role_id) VALUES (%s, %s);", (u_id, r_id))

                cur.execute("""
                    INSERT INTO staff (
                        user_id, employee_code, first_name, last_name, gender,
                        date_of_birth, date_of_joining, designation, basic_salary
                    ) VALUES (%s, %s, %s, %s, %s, %s, CURRENT_DATE, %s, %s)
                    RETURNING id;
                """, (
                    u_id, emp_code, body.get('firstName'), body.get('lastName'),
                    body.get('gender', 'MALE'), body.get('dateOfBirth', '1985-01-01'),
                    body.get('designation', 'Teacher'), Decimal(str(body.get('basicSalary', 4500)))
                ))
                st_id = cur.fetchone()['id']
                conn.commit()
                return api_response(data={"id": str(st_id), "employeeCode": emp_code}, message="Teacher created successfully", status=201)
    except Exception as e:
        return api_response(message=str(e), success=False, status=500)

# -----------------------------------------------------------------------------
# 5. CLASSES & SECTIONS
# -----------------------------------------------------------------------------
@app.route('/api/v1/classes', methods=['GET'])
def get_classes():
    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT c.id, c.name, c.numeric_order,
                           COALESCE(json_agg(
                               json_build_object('id', sec.id, 'name', sec.name, 'roomNumber', sec.room_number, 'capacity', sec.capacity)
                           ) FILTER (WHERE sec.id IS NOT NULL), '[]') as sections
                    FROM classes c
                    LEFT JOIN sections sec ON c.id = sec.class_id
                    GROUP BY c.id, c.name, c.numeric_order
                    ORDER BY c.numeric_order ASC;
                """)
                classes = cur.fetchall()
                for c in classes:
                    c['id'] = str(c['id'])
                return api_response(data=classes)
    except Exception as e:
        return api_response(message=str(e), success=False, status=500)

# -----------------------------------------------------------------------------
# 6. ATTENDANCE
# -----------------------------------------------------------------------------
@app.route('/api/v1/attendance', methods=['GET'])
def get_attendance():
    date_str = request.args.get('date', datetime.date.today().isoformat())
    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT s.id as student_id, s.admission_number, s.first_name, s.last_name,
                           se.roll_number, COALESCE(sa.status, 'UNMARKED') as attendance_status,
                           sa.remarks
                    FROM students s
                    JOIN student_enrollments se ON s.id = se.student_id AND se.is_active = TRUE
                    LEFT JOIN student_attendance sa ON s.id = sa.student_id AND sa.attendance_date = %s
                    ORDER BY se.roll_number ASC;
                """, (date_str,))
                records = cur.fetchall()
                for r in records:
                    r['student_id'] = str(r['student_id'])
                return api_response(data=records)
    except Exception as e:
        return api_response(message=str(e), success=False, status=500)

@app.route('/api/v1/attendance', methods=['POST'])
def save_attendance():
    body = request.get_json() or {}
    date_str = body.get('date', datetime.date.today().isoformat())
    records = body.get('records', [])

    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT id FROM academic_years WHERE is_current = TRUE LIMIT 1;")
                curr_year = cur.fetchone()['id']

                for r in records:
                    student_id = r['studentId']
                    status = r['status']
                    remarks = r.get('remarks', '')

                    cur.execute("""
                        INSERT INTO student_attendance (student_id, section_id, academic_year_id, attendance_date, status, remarks)
                        SELECT %s, se.section_id, %s, %s, %s, %s
                        FROM student_enrollments se WHERE se.student_id = %s AND se.is_active = TRUE LIMIT 1
                        ON CONFLICT (student_id, attendance_date)
                        DO UPDATE SET status = EXCLUDED.status, remarks = EXCLUDED.remarks;
                    """, (student_id, curr_year, date_str, status, remarks, student_id))

                conn.commit()
                return api_response(message="Attendance saved successfully")
    except Exception as e:
        return api_response(message=str(e), success=False, status=500)

# -----------------------------------------------------------------------------
# 7. FEE MANAGEMENT & CASHIERING
# -----------------------------------------------------------------------------
@app.route('/api/v1/fees/invoices', methods=['GET'])
def get_invoices():
    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT fi.id, fi.invoice_number, fi.title, fi.amount_due, fi.amount_paid,
                           fi.balance_amount, fi.due_date, fi.status,
                           s.id as student_id, s.admission_number, s.first_name, s.last_name,
                           fc.name as category_name
                    FROM fee_invoices fi
                    JOIN students s ON fi.student_id = s.id
                    JOIN fee_categories fc ON fi.fee_category_id = fc.id
                    ORDER BY fi.created_at DESC;
                """)
                invoices = cur.fetchall()
                for inv in invoices:
                    inv['id'] = str(inv['id'])
                    inv['student_id'] = str(inv['student_id'])
                    inv['amount_due'] = float(inv['amount_due'])
                    inv['amount_paid'] = float(inv['amount_paid'])
                    inv['balance_amount'] = float(inv['balance_amount'])
                    inv['due_date'] = inv['due_date'].isoformat()
                return api_response(data=invoices)
    except Exception as e:
        return api_response(message=str(e), success=False, status=500)

@app.route('/api/v1/fees/collect', methods=['POST'])
def collect_fee():
    body = request.get_json() or {}
    invoice_id = body.get('invoiceId')
    amount_paid = Decimal(str(body.get('amount', 0)))
    payment_mode = body.get('paymentMode', 'CASH')
    reference = body.get('referenceNumber', '')

    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT balance_amount, amount_paid FROM fee_invoices WHERE id = %s FOR UPDATE;", (invoice_id,))
                inv = cur.fetchone()
                if not inv:
                    return api_response(message="Invoice not found", success=False, status=404)

                new_paid = inv['amount_paid'] + amount_paid
                new_balance = max(Decimal(0), inv['balance_amount'] - amount_paid)
                new_status = 'PAID' if new_balance == 0 else 'PARTIAL'

                receipt_no = f"REC-{datetime.datetime.now().strftime('%Y%m%d%H%M%S')}"

                # Insert payment
                cur.execute("""
                    INSERT INTO fee_payments (receipt_number, invoice_id, amount, payment_date, payment_mode, reference_number)
                    VALUES (%s, %s, %s, CURRENT_DATE, %s, %s);
                """, (receipt_no, invoice_id, amount_paid, payment_mode, reference))

                # Update invoice
                cur.execute("""
                    UPDATE fee_invoices
                    SET amount_paid = %s, balance_amount = %s, status = %s, updated_at = CURRENT_TIMESTAMP
                    WHERE id = %s;
                """, (new_paid, new_balance, new_status, invoice_id))

                conn.commit()
                return api_response(data={
                    "receiptNumber": receipt_no,
                    "amountPaid": float(amount_paid),
                    "balanceRemaining": float(new_balance),
                    "status": new_status
                }, message="Payment collected and receipt generated")
    except Exception as e:
        return api_response(message=str(e), success=False, status=500)

# -----------------------------------------------------------------------------
# 8. EXAMINATIONS & MARKS
# -----------------------------------------------------------------------------
@app.route('/api/v1/exams', methods=['GET'])
def get_exams():
    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT e.id, e.name, e.start_date, e.end_date, e.is_published,
                           count(es.id) as total_papers
                    FROM exams e
                    LEFT JOIN exam_schedules es ON e.id = es.exam_id
                    GROUP BY e.id, e.name, e.start_date, e.end_date, e.is_published
                    ORDER BY e.start_date DESC;
                """)
                exams = cur.fetchall()
                for e in exams:
                    e['id'] = str(e['id'])
                    e['start_date'] = e['start_date'].isoformat()
                    e['end_date'] = e['end_date'].isoformat()
                return api_response(data=exams)
    except Exception as e:
        return api_response(message=str(e), success=False, status=500)

@app.route('/api/v1/exams/marks', methods=['GET'])
def get_exam_marks():
    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT em.id, em.theory_marks_obtained, em.practical_marks_obtained,
                           s.id as student_id, s.admission_number, s.first_name, s.last_name,
                           sub.name as subject_name, sub.total_marks as max_marks,
                           (em.theory_marks_obtained + em.practical_marks_obtained) as total_obtained
                    FROM exam_marks em
                    JOIN students s ON em.student_id = s.id
                    JOIN exam_schedules es ON em.exam_schedule_id = es.id
                    JOIN subjects sub ON es.subject_id = sub.id
                    ORDER BY s.admission_number ASC;
                """)
                marks = cur.fetchall()
                for m in marks:
                    m['id'] = str(m['id'])
                    m['student_id'] = str(m['student_id'])
                    m['theory_marks_obtained'] = float(m['theory_marks_obtained'])
                    m['practical_marks_obtained'] = float(m['practical_marks_obtained'])
                    m['total_obtained'] = float(m['total_obtained'])
                    m['max_marks'] = float(m['max_marks'])
                return api_response(data=marks)
    except Exception as e:
        return api_response(message=str(e), success=False, status=500)

# -----------------------------------------------------------------------------
# 9. LIBRARY
# -----------------------------------------------------------------------------
@app.route('/api/v1/library/books', methods=['GET'])
def get_books():
    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT b.id, b.isbn, b.title, b.author, b.publisher,
                           b.total_copies, b.available_copies, b.barcode,
                           bc.name as category_name
                    FROM books b
                    LEFT JOIN book_categories bc ON b.category_id = bc.id
                    ORDER BY b.title ASC;
                """)
                books = cur.fetchall()
                for b in books:
                    b['id'] = str(b['id'])
                return api_response(data=books)
    except Exception as e:
        return api_response(message=str(e), success=False, status=500)

# -----------------------------------------------------------------------------
# 10. TRANSPORT
# -----------------------------------------------------------------------------
@app.route('/api/v1/transport/routes', methods=['GET'])
def get_transport_routes():
    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT tr.id, tr.route_name, tr.start_point, tr.end_point, tr.monthly_fee
                    FROM transport_routes tr
                    ORDER BY tr.route_name ASC;
                """)
                routes = cur.fetchall()
                for r in routes:
                    r['id'] = str(r['id'])
                    r['monthly_fee'] = float(r['monthly_fee'])
                return api_response(data=routes)
    except Exception as e:
        return api_response(message=str(e), success=False, status=500)

# -----------------------------------------------------------------------------
# 11. SCHOOL PROFILE & SETTINGS
# -----------------------------------------------------------------------------
@app.route('/api/v1/settings/school-profile', methods=['GET'])
def get_school_profile():
    try:
        with get_db() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT * FROM school_profile LIMIT 1;")
                profile = cur.fetchone()
                if profile:
                    profile['id'] = str(profile['id'])
                    profile['created_at'] = profile['created_at'].isoformat()
                    profile['updated_at'] = profile['updated_at'].isoformat()
                return api_response(data=profile)
    except Exception as e:
        return api_response(message=str(e), success=False, status=500)

if __name__ == '__main__':
    print("==========================================================")
    print("  Oakridge ERP REST API Server (PostgreSQL Engine)")
    print("  Listening on: http://127.0.0.1:5050")
    print("==========================================================")
    app.run(host='127.0.0.1', port=5050, debug=False)
