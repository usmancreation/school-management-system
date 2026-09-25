# Database Design Document: Enterprise School Management ERP
**Database Engine:** PostgreSQL 15+ / 16  
**Architecture:** Normalized 3NF / BCNF with Strategic Denormalization for Financial Audit Trails  
**Schema Standard:** UUID v4 Primary Keys, Strict Foreign Key Cascades, Index Optimization, Flyway Version Control  

---

## 1. Entity-Relationship (ER) Diagram

```mermaid
erDiagram
    USERS ||--o{ USER_ROLES : has
    ROLES ||--o{ USER_ROLES : assigned_to
    ROLES ||--o{ ROLE_PERMISSIONS : has
    PERMISSIONS ||--o{ ROLE_PERMISSIONS : assigned_to

    ACADEMIC_YEARS ||--o{ CLASSES : defines
    CLASSES ||--o{ SECTIONS : divides_into
    CLASSES ||--o{ SUBJECTS : contains
    
    STUDENTS ||--o{ STUDENT_ENROLLMENTS : enrolls
    SECTIONS ||--o{ STUDENT_ENROLLMENTS : contains
    ACADEMIC_YEARS ||--o{ STUDENT_ENROLLMENTS : applies_to
    
    STUDENTS ||--o{ GUARDIANS : has
    STUDENTS ||--o{ ATTENDANCE : records
    STUDENTS ||--o{ EXAM_MARKS : receives
    STUDENTS ||--o{ FEE_INVOICES : billed_to
    
    TEACHERS ||--o{ TIMETABLE_SLOTS : scheduled_for
    SUBJECTS ||--o{ TIMETABLE_SLOTS : taught_in
    SECTIONS ||--o{ TIMETABLE_SLOTS : attends
    
    EXAMS ||--o{ EXAM_SCHEDULES : consists_of
    SUBJECTS ||--o{ EXAM_SCHEDULES : examined_in
    EXAM_SCHEDULES ||--o{ EXAM_MARKS : records
    
    FEE_STRUCTURES ||--o{ FEE_INVOICES : generates
    FEE_INVOICES ||--o{ FEE_PAYMENTS : paid_via
    FEE_PAYMENTS ||--o{ FEE_RECEIPTS : produces

    BOOKS ||--o{ BOOK_ISSUES : checked_out
    STUDENTS ||--o{ BOOK_ISSUES : borrows
    
    ROUTES ||--o{ VEHICLES : assigned_to
    VEHICLES ||--o{ DRIVERS : operated_by
    STUDENTS ||--o{ STUDENT_TRANSPORT : uses
    ROUTES ||--o{ STUDENT_TRANSPORT : routes
```

---

## 2. Relational Schema Architecture

The database is divided into logical domain areas:
1. **Core & Identity**: `users`, `roles`, `permissions`, `user_roles`, `role_permissions`, `audit_logs`, `school_profile`.
2. **Academic Structure**: `academic_years`, `classes`, `sections`, `subjects`, `teacher_subjects`, `timetable_slots`.
3. **Student Lifecycle**: `students`, `guardians`, `student_enrollments`, `student_documents`.
4. **Staff & Human Resources**: `staff`, `teachers`, `departments`, `designations`, `staff_leaves`, `payroll_records`.
5. **Attendance Engine**: `student_attendance`, `staff_attendance`.
6. **Examination & Assessment**: `exams`, `grade_scales`, `exam_schedules`, `exam_marks`, `report_cards`.
7. **Fee & Financial Governance**: `fee_categories`, `fee_structures`, `fee_invoices`, `fee_discounts`, `fee_payments`, `fee_receipts`, `expenses`, `income_ledger`.
8. **Operations & Facilities**: `books`, `book_categories`, `book_issues`, `routes`, `vehicles`, `drivers`, `student_transport`, `hostel_rooms`, `inventory_items`.
