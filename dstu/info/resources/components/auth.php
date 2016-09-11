<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=windows-1251" />
	<title>
		SL CMS - Авторизация
	</title>
</head>
<body>
<form method="post" name="News" action="<?php echo $RootMain.$_REQUEST['page']; ?>">
<?php echo $AMessage.'<br>';?>
Логин<br>
<input name="login" type="text"/><br>
Пароль<br>
<input name="password" type="password"/><br>
<input name="confirm" type="submit" value='OK'/>
<form>
</body>
</html>
