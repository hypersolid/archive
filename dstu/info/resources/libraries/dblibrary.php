<?php
 require_once($_SERVER['DOCUMENT_ROOT'].'/resources/settings/directories.php');
 require_once($DirectorySettings.'dbconfig.php');
/**************************************************************************************************************************************************/
function SQL_CREATE_DB($db)
{
	@mysql_query("CREATE DATABASE $db") or Error ("Could not create database '$db': <br>".mysql_error());
}
function SQL_CREATE_TABLE($table,$fields) {
	@mysql_query("CREATE TABLE $table($fields)") or Error("Can not create table '$table': <br>".mysql_error());
}
 function SQL_INSERT($table,$kv)
 {
	$query="INSERT INTO $table SET ";
	$i=0;
	$q1=$q2="";
	foreach ($kv as $key=>$value)
	{
		$q1.=$key;
		$q2.="'".$value."'";
		if (++$i!=count($kv))
		{
			$q1.=', ';
			$q2.=', ';
		}
	}
	$query="INSERT INTO $table($q1) VALUES($q2)";
	@mysql_query($query) or Error("Can not insert in $table: ".mysql_error());
 }
 function SQL_SELECT($table,$fields,$condition)
 {
	$query="SELECT $fields FROM $table WHERE $condition";
	$result=mysql_query($query) or Error("Can not select from table '$table': <br>".mysql_error());
	for ($data=array();$row=mysql_fetch_assoc($result);$data[]=$row);
	return $data;
 }
 function SQL_CLEAR_TABLE($table)
 {
	@mysql_query("DELETE FROM $table WHERE 1")  or Error("Can not clear table '$table': <br>".mysql_error());
 }
 function SQL_DELETE($table,$condition)
 {
	@mysql_query("DELETE FROM $table WHERE $condition") or Error("Can not delete fields from table '$table': <br>".mysql_error());
 }
 function SQL_UPDATE($table,$kv,$condition)
 {
	$Query="UPDATE $table SET ";
	$i=0;
	foreach ($kv as $key=>$value)
	{
		$Query.=$key.'='."'".$value."'";
		if (++$i!=count($kv))
		{
			$Query.=', ';
		}
	}
	$Query.=" WHERE $condition;"; 
	@mysql_query($Query) or Error("Can not update fields from table '$table': <br>".mysql_error());
 }
/**************************************************************************************************************************************************/
 function SQL_news_INSERT($time,$head,$content)
 {
	$Query['time']=$time;
	$Query['head']=$head;
	$Query['content']=$content;
	SQL_INSERT('ddm_news',$Query);
 }
 function SQL_permissions_INSERT($owner,$permissions)
 {
	$Query['owner']=$owner;
	$Query['permissions']=$permissions;
	SQL_INSERT('ddm_permissions',$Query);
 }
 function SQL_admin_INSERT($name,$surname,$mail,$login,$pass,$V,$U,$C,$D,$M)
 {
	$Query['name']=$name;
	$Query['surname']=$surname;
	$Query['mail']=$mail;
	$Query['login']=$login;
    $Query['pass']=md5($pass);
    $Query['V']=$V;
    $Query['U']=$U;
    $Query['C']=$C;
    $Query['D']=$D;
    $Query['M']=$M;
	SQL_INSERT('ddm_admins',$Query);
 }
/**************************************************************************************************************************************************/
 mysql_connect($host,$user,$password) or Error('Could not connect to database: '.mysql_error()); 
//SQL_CREATE_DB($db);
 mysql_select_db($db) or Error('Could not select database: '.mysql_error());
/**************************************************************************************************************************************************
SQL_CREATE_TABLE('ddm_news','id INT AUTO_INCREMENT PRIMARY KEY,time TINYTEXT,head TINYTEXT,content TEXT');
/**************************************************************************************************************************************************
SQL_CREATE_TABLE('ddm_admins','id INT AUTO_INCREMENT PRIMARY KEY,name TINYTEXT,surname TINYTEXT,mail TINYTEXT,login TINYTEXT,pass TINYTEXT,V INT,U INT,C INT,D INT,M INT');
/**************************************************************************************************************************************************
SQL_admin_INSERT('Александр','DoomsDAY',"",'doom','killa',1,1,1,1,1);
/**************************************************************************************************************************************************
SQL_CREATE_TABLE('ddm_permissions','id INT AUTO_INCREMENT PRIMARY KEY,owner INT,permissions TEXT');
/************************************************************************/
?>