<?php
// Cross Origin Access
require('config/cors.php');
require('config/connection.php');

$patient_id=$_POST["patient_id"];
$approval=$_POST["approval"];
$table=$_POST["tb"];
$action=$_POST["action"];


if($action=="updatereq"){


  $sql = "UPDATE $table SET approval='$approval' WHERE patient_id = $patient_id ";
        if($conn->query($sql) === TRUE){
            echo "success";
        }else{
            echo "error";
        }


$conn->close();
return;
}

?>