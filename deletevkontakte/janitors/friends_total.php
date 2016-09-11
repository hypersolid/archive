<?php
require 'base.php';
$result = api('friends.get',array())->response;
if (is_array($result)) {
	echo count($result);
} else {
	echo 0;
};
?>
