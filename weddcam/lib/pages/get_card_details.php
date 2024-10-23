<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Connect to MySQL
$servername = "localhost";
$username = "amplepac_root";
$password = '3]H_iTKr6XK~';
$dbname = "amplepac_tebozdb";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get data from the POST request
$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['card_number'])) {
    echo json_encode(["status" => "error", "message" => "Missing required fields."]);
    exit;
}

$card_number = $conn->real_escape_string($_GET['card_number']);

// Prepare the SQL statement
$sql = "SELECT FirstName, LastName, CardNumber, CardType, Status FROM attendance_records WHERE CardNumber = '$card_number'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $cardDetails = $result->fetch_assoc();
    echo json_encode($cardDetails);
} else {
    echo json_encode(["status" => "error", "message" => "No records found."]);
}

$conn->close();
?>