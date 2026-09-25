<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . "/../../config/database.php";

$database = new Database();
$db = $database->getConnection();

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $search = isset($_GET['search']) ? trim($_GET['search']) : '';
    $query = "SELECT s.id, s.admission_number, s.first_name, s.last_name, s.gender,
                     s.date_of_birth, s.blood_group, s.email, s.phone, s.status,
                     c.name as class_name, sec.name as section_name, se.roll_number
              FROM students s
              LEFT JOIN student_enrollments se ON s.id = se.student_id AND se.is_active = TRUE
              LEFT JOIN sections sec ON se.section_id = sec.id
              LEFT JOIN classes c ON sec.class_id = c.id
              WHERE (:search = '' OR s.first_name ILIKE :term OR s.last_name ILIKE :term OR s.admission_number ILIKE :term)
              ORDER BY s.admission_number ASC";
    
    $stmt = $db->prepare($query);
    $term = "%{$search}%";
    $stmt->bindParam(":search", $search);
    $stmt->bindParam(":term", $term);
    $stmt->execute();
    
    $students = $stmt->fetchAll();
    echo json_encode([
        "success" => true,
        "message" => "Students retrieved successfully",
        "data" => $students
    ]);
} elseif ($method === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);
    
    // Generate admission number
    $countStmt = $db->query("SELECT count(*) as total FROM students");
    $total = $countStmt->fetch()['total'] + 1;
    $admNo = sprintf("SCH-2025-%03d", $total);

    $insert = "INSERT INTO students (admission_number, admission_date, first_name, last_name, gender, email, phone, current_address)
               VALUES (:adm, CURRENT_DATE, :fn, :ln, :gender, :email, :phone, :address) RETURNING id";
    $stmt = $db->prepare($insert);
    $stmt->execute([
        ':adm' => $admNo,
        ':fn' => $data['firstName'] ?? '',
        ':ln' => $data['lastName'] ?? '',
        ':gender' => $data['gender'] ?? 'MALE',
        ':email' => $data['email'] ?? '',
        ':phone' => $data['phone'] ?? '',
        ':address' => $data['address'] ?? ''
    ]);
    $newId = $stmt->fetch()['id'];

    echo json_encode([
        "success" => true,
        "message" => "Student enrolled successfully",
        "data" => ["id" => $newId, "admissionNumber" => $admNo]
    ]);
}
