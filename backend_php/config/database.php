<?php
// =============================================================================
// PostgreSQL PDO Database Connection
// =============================================================================

class Database {
    private $host = "localhost";
    private $db_name = "school_erp";
    private $username = "postgres";
    private $password = "admin123"; // or configured pgAdmin password
    private $port = "5432";
    public $conn;

    public function getConnection() {
        $this->conn = null;
        try {
            $dsn = "pgsql:host=" . $this->host . ";port=" . $this->port . ";dbname=" . $this->db_name;
            $this->conn = new PDO($dsn, $this->username, $this->password, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
            ]);
        } catch (PDOException $exception) {
            echo json_encode([
                "success" => false,
                "message" => "Connection error: " . $exception->getMessage()
            ]);
            exit;
        }
        return $this->conn;
    }
}
