<?php
// Cross Origin Access
require('config/cors.php');
require('config/connection.php');


$msg = "";
$patient_id=$_POST["patient_id"];
$filename=$_FILES["file"]["name"];
$tempname=$_FILES["file"]["tmp_name"];
$folder="reports/".$filename;
$action=$_POST["action"];
$table=$_POST["tb"];


if($action=="uploadreport"){

        $sql = "UPDATE $table SET report='$filename' WHERE patient_id = $patient_id ";
        if($conn->query($sql) === TRUE){
            
           if (move_uploaded_file($tempname, $folder))  {
            $msg = "Image uploaded successfully";
           }else{
              $msg = "Failed to upload image";
            }
            echo "$msg";
        }else{
            echo "error";
        }


$conn->close();
return;

}



?>