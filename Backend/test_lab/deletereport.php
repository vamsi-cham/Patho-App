<?php
// Cross Origin Access
require('config/cors.php');
require('config/connection.php');


$patient_id=$_POST["patient_id"];
$report=$_POST["report"];
$table=$_POST["tb"];
$action=$_POST["action"];


if($action=="deletereport"){


  $sql = "UPDATE $table SET report='$report' WHERE patient_id = $patient_id ";
        if($conn->query($sql) === TRUE){
            echo "success";
        }else{
            echo "error";
        }


$conn->close();
return;
}

?>