<?php
// Cross Origin Access
require('config/cors.php');
require('config/connection.php');

$mobile=$_POST["mobile"];
$role=$_POST["role"];
$name=$_POST["name"];
$table=$_POST["tb"];
$action=$_POST["action"];


if($action=="setprofile"){


  $sql = "UPDATE $table SET name='$name', role='$role' WHERE mobile = '$mobile' ";
        if($conn->query($sql) === TRUE){
            echo "success";
        }else{
            echo "error";
        }


$conn->close();
return;
}

?>