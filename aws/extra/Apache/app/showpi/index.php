<?php
$servername = getenv('BDPI_ADDR');
$username = getenv('BDPI_USER');
$password = getenv('BDPI_PASS');
$dbname = getenv('BDPI_DATABASE');

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
//
$sql = "SELECT pi FROM pinum";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    // output data of each row
    while($row = $result->fetch_assoc()) {
        echo "PiNum : " . $row["pi"]. "<br>";
    }
} else {
    echo "0 results";
}
$conn->close();
?> 
