<?php 
require_once($_SERVER['DOCUMENT_ROOT'].'/resources/settings/directories.php'); 
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF8" />
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">
<meta http-equiv="pragma" content="no-cache">
	<title>
		<?php echo (isset($TITLE)?$TITLE:'');?>   
	</title>
	<link href="favicon.ico" rel="shortcut icon" type="image/ico">
	<link rel="stylesheet" type="text/css" href="<?php echo $RootAdmin;?>design/eskin/styles/style.css">
	<link rel="stylesheet" type="text/css" href="<?php echo $RootAdmin;?>design/iskin/styles/style.css">
</head>
