<?php
// Cross Origin Access
require('config/cors.php');
require('config/connection.php');



$lab_id=$_POST["lab_id"];
$lab_name=$_POST["lab_name"];
$lab_type=$_POST["lab_type"];
$patient_name=$_POST["patient_name"];
$mobile=$_POST["mobile"];
$action=$_POST["action"];
$table=$_POST["tb"];


if($action=="addpatient"){

        $sql = "INSERT INTO $table (lab_id,lab_name,lab_type,patient_name,mobile) VALUES ($lab_id,'$lab_name','$lab_type','$patient_name','$mobile')";
        $result = $conn->query($sql);
        echo json_encode("success");
        $conn->close();
        return;


}



?>