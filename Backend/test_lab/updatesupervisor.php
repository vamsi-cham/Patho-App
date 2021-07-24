<?php
// Cross Origin Access
require('config/cors.php');
require('config/connection.php');


$lab_id=$_POST["lab_id"];
$name=$_POST["name"];
$mobile=$_POST["mobile"];
$table=$_POST["tb"];
$action=$_POST["action"];


if($action=="updatesupervisor"){


  $sql = "UPDATE $table SET name='$name', mobile='$mobile' WHERE lab_id = $lab_id ";
        if($conn->query($sql) === TRUE){
            echo "success";
        }else{
            echo "error";
        }


$conn->close();
return;
}

?>