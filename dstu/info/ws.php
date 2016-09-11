<?php 
require_once($_SERVER['DOCUMENT_ROOT'].'/resources/settings/directories.php');
require_once($DirectoryLib.'dblibrary.php');
$out='<?xml version="1.0" encoding="UTF-8" ?>';
$out.='<files>';
$result = SQL_SELECT(ddm_files,'*','1 order by id limit 0,10');
foreach ($result as $item)
	{	
	$out.='<item>';
	foreach ($item as $key=>$value)
		{
			$out.="<$key>$value</$key>";
		}
	$out.='</item>';
	}
$out.='</files>';
echo mb_convert_encoding($out,'utf-8','koi8-r'); 
?>
