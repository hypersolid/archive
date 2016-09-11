<?php
require 'base.php';

$step = 10;
$result = api('photos.getAll',array())->response;
$total_size = $result[0];
$size = ($total_size > $step+1 ? $step : $total_size);

if ($total_size >0) {
	for ($i=1;$i<$size+1;$i++)
	{
		$obj = $result[$i];
		api('photos.delete',array('pid' => $obj->pid));
	};
	echo $total_size-$size;
} else {
	echo 0;
};
?>
