<?php

$username = 'u666708222_testlab';
$password = 'Testlab54321';
$dbname = 'u666708222_testlab';
$servername = 'localhost';
$port=3306;

$conn = mysqli_connect($servername, $username, $password, $dbname, $port);

if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}

?>