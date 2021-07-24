<?php
// Cross Origin Access
require('config/cors.php');
require('config/connection.php');

$phone=$_POST["phone"];
$name=$_POST["name"];
$mobile=$_POST["mobile"];
$table=$_POST["tb"];
$action=$_POST["action"];


if($action=="updateuser"){


  $sql = "UPDATE $table SET name='$name', mobile='$mobile' WHERE mobile = '$phone' ";
        if($conn->query($sql) === TRUE){
            echo "success";
        }else{
            echo "error";
        }


$conn->close();
return;
}

?>