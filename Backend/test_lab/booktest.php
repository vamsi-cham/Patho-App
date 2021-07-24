<?php
// Cross Origin Access
require('config/cors.php');
require('config/connection.php');

$test_type=$_POST["test_type"];
$customer_mobile=$_POST["customer_mobile"];
$lab_id=$_POST["lab_id"];
$name=$_POST["name"];
$mobile=$_POST["mobile"];
$address=$_POST["address"];
$action=$_POST["action"];
$table=$_POST["tb"];


if($action=="booktest"){

        $sql = "INSERT INTO $table (customer_mobile,name,mobile,address,lab_id,test_type) VALUES ('$customer_mobile','$name','$mobile','$address','$lab_id','$test_type')";
        $result = $conn->query($sql);

        echo json_encode("success");
        $conn->close();
        return;


}



?>