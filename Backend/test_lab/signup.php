<?php
// Cross Origin Access
require('config/cors.php');
require('config/connection.php');



$mobile=$_POST["mobile"];
$action=$_POST["action"];
$table=$_POST["tb"];


if($action=="signup"){

        $sql = "INSERT INTO $table (mobile) VALUES ('$mobile')";
        $result = $conn->query($sql);

        echo json_encode("success");
        $conn->close();
        return;


}



?>