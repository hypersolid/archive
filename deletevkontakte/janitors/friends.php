<?php
require 'base.php';

$step = 10;
$result = api('friends.get',array())->response;
$total_size = count($result);
$size = ($total_size > $step ? $step : $total_size);

if (is_array($result)) {
	for ($i=0;$i<$size;$i++)
	{
		api('friends.delete',array('uid'=>$result[$i]));
	};
	echo $total_size-$size;
} else {
	echo '0';
};
?>
