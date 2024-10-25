<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

// Connect to MySQL
$servername = "localhost";
$username = "esitortz_root"; // Your MySQL username
$password = 'YangaB1ngwa'; // Your MySQL password
$dbname = "esitortz_app";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

// Get the card number from the query parameter
$cardNumber = $conn->real_escape_string($_GET['card_number']);

// Prepare the SQL statement
$sql = "SELECT * FROM attendance_records WHERE CardNumber = '$cardNumber'";
$result = $conn->query($sql);

// Check if a record was found
if ($result->num_rows > 0) {
    $record = $result->fetch_assoc();
    echo json_encode(["status" => "success", "data" => $record]);
} else {
    echo json_encode(["status" => "error", "message" => "No record found"]);
}

// Close connection
$conn->close();
?>