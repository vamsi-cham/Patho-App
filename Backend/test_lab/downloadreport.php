<?php
// Cross Origin Access
require('config/cors.php');
require('config/connection.php');


$msg = "";
$filename=$_POST["filename"];
$filepath = 'reports/'.$filename;



if (file_exists($filepath)) {

        header('Content-Description: File Transfer');
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename=' . basename($filepath));
        header('Expires: 0');
        header('Cache-Control: must-revalidate');
        header('Pragma: public');
        header('Content-Length: ' . filesize('reports/'.$filename));
        readfile('reports/'.$filename);


$conn->close();
return;

}



?>