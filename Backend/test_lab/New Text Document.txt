<?php
// Cross Origin Access
require('config/cors.php');
require('config/connection.php');


$lab_id=$_POST["lab_id"];
$lab_name=$_POST["lab_name"];
$lab_type=$_POST["lab_type"];
$table=$_POST["tb"];
$action=$_POST["action"];


if($action=="updatelab"){


  $sql = "UPDATE $table SET lab_name='$lab_name', lab_type='$lab_type' WHERE lab_id = $lab_id ";
        if($conn->query($sql) === TRUE){
            echo "success";
        }else{
            echo "error";
        }


$conn->close();
return;
}

?>