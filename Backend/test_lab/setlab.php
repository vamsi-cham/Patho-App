<?php
// Cross Origin Access
require('config/cors.php');
require('config/connection.php');


$name=$_POST["name"];
$mobile=$_POST["mobile"];
$lab_name=$_POST["lab_name"];
$lab_type=$_POST["lab_type"];
$action=$_POST["action"];
$table=$_POST["tb"];


if($action=="setlab"){

        $sql = "INSERT INTO $table (name,mobile,lab_name,lab_type) VALUES ('$name','$mobile','$lab_name','$lab_type')";
        $result = $conn->query($sql);

        echo json_encode("success");
        $conn->close();
        return;


}



?>