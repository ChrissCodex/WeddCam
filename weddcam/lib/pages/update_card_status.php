<?php
  header('Content-Type: application/json');
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


  // Simulating input for this example
  $json = file_get_contents('php://input');
  $data = json_decode($json, true);

  if (isset($data['card_number']) && isset($data['status'])) {
    $cardNumber = $data['card_number'];
    $status = $data['status'];

    // Perform the database update here (update status to 'Scanned')
    // Example:
    $sql = "UPDATE attendance_records SET Status='Scanned' WHERE CardNumber='$cardNumber'";
    // Execute your SQL query here...

    // Send a success response
    echo json_encode(['status' => 'success', 'message' => 'Card status updated successfully']);
  } else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid inputs']);
  }
?>