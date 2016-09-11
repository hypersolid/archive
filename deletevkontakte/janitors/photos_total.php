<?php
require 'base.php';
$result = api('photos.getAll',array())->response;
echo $result[0];
?>
