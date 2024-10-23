<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Connect to MySQL
$servername = "localhost";
$username = "amplepac_root"; // Your MySQL username
$password = '3]H_iTKr6XK~'; // Your MySQL password
$dbname = "amplepac_tebozdb";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get data from the POST request
$data = json_decode(file_get_contents("php://input"), true);

// Sanitize inputs
$firstName = $conn->real_escape_string($data['first_name']);
$lastName = $conn->real_escape_string($data['last_name']);
$cardNumber = $conn->real_escape_string($data['card_number']);
$cardType = $conn->real_escape_string($data['card_type']);
$qrCodeImage = $conn->real_escape_string($data['qr_code_image']); // New field for the QR code image

// Prepare the SQL statement
$sql = "INSERT INTO attendance_records (FirstName, LastName, CardNumber, CardType, QrCodeImage,Status) VALUES ('$firstName', '$lastName', '$cardNumber', '$cardType', '$qrCodeImage', 'Not Scanned')";

// Execute the query
if ($conn->query($sql) === TRUE) {
    echo json_encode(["status" => "success", "message" => "Record added successfully"]);
} else {
    echo json_encode(["status" => "error", "message" => "Error: " . $sql . "<br>" . $conn->error]);
}

// Close connection
$conn->close();
?>