 <?php
//logging start
$log=fopen($DirectoryRoot.'system/log.txt',"a");
$tablename = "ddm_files";
 if (!defined('DDMEngine'))
{
	exit;
}
else
{
//access graduation
$AG=0;
$permissions=SQL_SELECT('ddm_permissions','permissions',"owner='".$_SESSION['ident']."'");
$permissions=$permissions[0]['permissions'];
$nPOSTFIX=str_replace('/','',$POSTFIX);
if (strpos($permissions,$nPOSTFIX.';')!==false||strpos($permissions,"!ALL")!==false)
{
$AG=1;
}
/****************Infiltrate**************************************************************************************/
@ $RSEND=$_REQUEST['path'];
$PATH=InfiltrateL('path');
$SMODE=InfiltrateL('SMode');
$PARAMETERID=InfiltrateM('ParameterID');
/*$A=array();
$A=explode('/',$PATH);
unset($A[0]);
$PATH=implode('/',$A);*/
/*************Directory Check***************************************************************************************************************/

if (is_dir($DirectoryRoot.'files/'.$POSTFIX.$PATH.'/' ))
{
	if ($SMODE=='DF'  && $AG)
	{
		DeleteFolder($DirectoryRoot.'files/'.$POSTFIX.$PARAMETERID.'/');
fwrite($log,date('H:i:s / d-F-Y')." User ".$_SESSION['name'].' '.$_SESSION['surname'].' have deleted folder '.$DirectoryRoot.'files/'.$POSTFIX.$PARAMETERID.chr(13).chr(10));
	}
/*************Make Directory***************************************************************************************************************/	
	if ($SMODE=='MF'  && $AG)
	{
		if (!is_dir($PARAMETERID))
		{
			@ mkdir($PARAMETERID);
@fwrite($log,date('H:i:s / d-F-Y')." User ".$_SESSION['name'].' '.$_SESSION['surname'].' have made folder '.$PARAMETERIi.chr(13).chr(10));
			chmod($PARAMETERID,0777);
		}
	}
 /****************Delete********************************************************************************************************/	
	if ($SMODE=='D'  && $AG)
	{
		if (is_file($DirectoryRoot.'files/'.$PARAMETERID))
		{
			unlink($DirectoryRoot.'files/'.$PARAMETERID);
fwrite($log,date('H:i:s / d-F-Y')." User ".$_SESSION['name'].' '.$_SESSION['surname'].' have deleted file '.$DirectoryRoot.'files/'.$PARAMETERID.chr(13).chr(10));
$fnamed = 'files/'.$PARAMETERID;
$dquery="DELETE  FROM ddm_files WHERE flocate = '$fnamed'";
mysql_query($dquery);
		}
	}
/****************RC********************************************************************************************************/	
if ($SMODE=='RC'  && $AG)
	{
	
	$PARAMETERID=explode('|',$PARAMETERID);

//echo $DirectoryRoot.'files/'.$POSTFIX.($PATH?$PATH.'/':'').$PARAMETERID[0];
rename($DirectoryRoot.'files/'.$POSTFIX.($PATH?$PATH.'/':'').$PARAMETERID[0],$DirectoryRoot.'files/'.$POSTFIX.($PATH?$PATH.'/':'').$PARAMETERID[1]);

fwrite($log,date('H:i:s / d-F-Y')." User ".$_SESSION['name'].' '.$_SESSION['surname'].' has renamed file '.$DirectoryRoot.'files/'.$POSTFIX.($PATH?$PATH.'/':'').$PARAMETERID[0].' to '.$DirectoryRoot.'files/'.$POSTFIX.($PATH?$PATH.'/':'').$PARAMETERID[1].chr(13).chr(10));
$rfile1 = 'files/'.$POSTFIX.($PATH?$PATH.'/':'').$PARAMETERID[0];
$rfile2 = 'files/'.$POSTFIX.($PATH?$PATH.'/':'').$PARAMETERID[1];
$fnamed = 'files/'.$PARAMETERID;
$dquerys="UPDATE ddm_files set fname = '$PARAMETERID[1]' WHERE fname = '$PARAMETERID[0]'";
$pquery="UPDATE ddm_files set flocate = '$rfile2' WHERE flocate = '$rfile1'";
mysql_query($dquerys);
mysql_query($pquery);
}
/************Delete Checked*********************************************************************************************************/
if ($SMODE=='DC'  && $AG) 
{
	foreach ($_REQUEST as $key=>$value)
	{
		$key=urldecode($key);
		$target=$DirectoryRoot.'files/'.$POSTFIX.str_replace('\'','.',str_replace('..','',$key));
		if (is_file($target))
		{
			unlink($target);
fwrite($log,date('H:i:s / d-F-Y')." User ".$_SESSION['name'].' '.$_SESSION['surname'].' have deleted file '.$target.chr(13).chr(10));
		}
	}
}
/****************Upload ********************************************************************************************************/



 if ($SMODE=='U' && $AG)
 {
	$data=$_FILES['File'];
	if (preg_match('{msdownload|octet-stream}i',(isset($_FILES['File']['type'])?$_FILES['File']['type']:''))&& strpos($data['name'],'.odt')===false)
	{
		$mode=3;
	}
	else
	{
		if (!$data['error'])
		{
			$tmp=$data['tmp_name'];
			$name=$DirectoryRoot.'files/'.$POSTFIX.$PATH.'/'.$data['name'];
			if (!file_exists($name))
			{
				if (file_exists($tmp))
				{
					@move_uploaded_file($tmp,$name);
					chmod($name,0777);
fwrite($log,date('H:i:s / d-F-Y')." User ".$_SESSION['name'].' '.$_SESSION['surname'].' have uploaded file '.$name.chr(13).chr(10));
$flocate = 'files/'.$POSTFIX.$PATH.'/'.$data['name'];
$fname = $data['name'];
$fdate=date("Y-m-d");
//$selID1="select id from ddm_files order by id desc limit 1";
$query1 = "INSERT INTO ddm_files (fname,flocate,fdate) VALUES ('$fname','$flocate','$fdate')";
mysql_query($query1);
					$mode=1;
				}
				else
				{
					$mode=-1;
				}
			}
			else
			{
				$mode=2;
			}
		}
		else
		{
			$mode=-1;
		}
	}
 }
 else
 {
	$mode=0;
 }
 ?>
<script language="javascript" type="text/javascript">
<?php 
	
	if ($mode==-1) echo "alert('Файл не был загружен на сервер...');"; 
	if ($mode==1)  echo "alert('Файл успешно загружен на сервер.');";
	if ($mode==2)  echo "alert('Файл ".$data['name']." уже существует.');";
	if ($mode==3)  echo "alert('Файл не был загружен на сервер. \\nДанный формат файла не поддерживается.');";
?>
</script>
<?php 
/********************************BASE***************************************************************************************/
?>
<script language="javascript" type="text/javascript" src="<?php echo $RootAdmin?>functionality/base/changebackground.js"></script>
<script language="javascript" type="text/javascript">
	function NewFolder()
	{
		document.Files.SMode.value='MF';
		document.Files.ParameterID.value='<?php echo $DirectoryRoot.'files/'.$POSTFIX.(isset($PATH)?$PATH.'/':'');?>'+document.Files.title.value;
		if (document.Files.title.value)
		{	
			document.Files.submit();
		}
		else
		{
			alert('Введите название папки.');
		}
	}
	function Delete(C)
	{
		document.Files.SMode.value='D';
		document.Files.ParameterID.value='<?php echo $POSTFIX.urldecode($PATH);?>/'+C;
		document.Files.submit();
	}
	function Upload()
	{
		document.Files.SMode.value='U';
		document.Files.submit();
	}
	function Rename(C)
	{
		document.Files.SMode.value='R';
		document.Files.ParameterID.value=C;
		document.Files.submit();
	}
	function RC(C)
	{
		
		document.Files.SMode.value='RC';
		document.Files.ParameterID.value=C+'|'+document.Files.NRC.value;
		document.Files.submit();
	}
	function DeleteChecked()
	{
		document.Files.SMode.value='DC';
		var trigger=0;
		for (i = 0; i < document.Files.elements.length; i++)
		{
			var item=document.Files.elements[i];
			if (item.type == "checkbox" &&item.name!='AllCheck')  
			{	
				if (item.checked)
				{
					trigger=1;
				}
			}
		}
		if (trigger)
		{
		if (confirm('Вы действительно хотите удалить выбраные файлы?'))
		{
			document.Files.submit();
		}
		}
	}
	function DeleteFolder(C)
	{
		if (confirm('Вы действительно хотите удалить эту директорию, включая все документы, находящиеся в ней?'))
		{	
			document.Files.SMode.value='DF';
			document.Files.ParameterID.value=C;
			document.Files.submit();
		}
	}
	function CheckAll()
	{
		for (i = 0; i < document.Files.elements.length; i++)
		{
			var item=document.Files.elements[i];
			if (item.type == "checkbox")  
			{
		     item.checked = document.Files.AllCheck.checked;
			}
		}
	}
</script>
<form action="<?php echo $RootMain.$ACTION."&path=".str_replace("%2F","/",urlencode($PATH));?>" method="POST" name="Files" enctype="multipart/form-data" >
<input type="hidden" value="<?php echo $PATH?>" name="path">
<?php
NavigateFilesLocal($DirectoryRoot.'files/'.$POSTFIX,($PATH?$PATH.'/':''));
asort($Files);
asort($Folders);
?>
Текущий каталог:
<br>
<table style="font-size:16px;color:white;background-color:#00ccFF;padding-left:10px;width:100%">
	<tr>
		<td> 
			<a class="achoose" href="<?php echo $RootMain.$ACTION.'&path=';?>"><?php echo $ROOT;?></a>  
			<?php 
			$tmp=array();
			$tmp=explode('/',$PATH);
			$linker=$RootMain.$ACTION.'&path=';
			foreach ($tmp as $V)
			{
				$linker.=urlencode($V);
				echo ' / <a class="achoose" href="'.$linker.'">'.$V.'</a>';
				$linker.='/';
			}
			?>
		</td>
	</tr>
</table>
<br>





<?php
/************Rename*********************************************************************************************************/
if ($SMODE=='R'  && $AG) 
{
//fwrite($log,date('H:i:s / d-F-Y')." User ".$_SESSION['name'].' '.$_SESSION['surname'].' has renamed file  '.$PARAMETERID.chr(13).chr(10));
	



?>


Новое название <b>'<?php echo $PARAMETERID;?>'</b> <br>
<input type="text" name="NRC" value="<?php echo $PARAMETERID;?>" style="width:300px" name="path" /><br>
<input type="button" value="Переименовать"  style="width:300px" onclick ="javascript:RC('<?php echo $PARAMETERID;?>');"/>


<?php
}	
?>
<br>
<table style="border-width:1px;border-style:solid;border-color:#eeeeee;width:70%" cellpadding="0" cellspacing="0">
<tr>
	<td colspan="5">
		Папки:
	</td>
</tr>
	<?php if ($_SESSION['U']  && $AG) { ?>

<tr>
<td colspan="4">
			<table style="text-align:center;width:100%;border-width:1px;border-style:solid;border-color:#eeeeee">
				<tr>
					<td>
						<span style="padding-left:5px">
							<input type="text" name="title" value="" style="width:135px">
						</span>
						<input type="button" value="Создать новую папку" onclick="javascript:NewFolder();">
					</td>
				</tr>
			</table>
</td>
	<?php } ?>

</tr>
	<?php 
	$PATH=str_replace("%2F",'/',urlencode($PATH));
	//Folders
	if ($PATH)
	{
		$tmp=explode('/',$PATH);
		unset($tmp[count($tmp)-1]);
		$tmp=implode('/',$tmp);
	?>
	<tr align="center" bgcolor="#eeeeee" id="R-1"  onmouseover="FBA('R-1');" onmouseout="FBP('R-1');" onclick="javascript:window.location='<?php echo $RootMain.$ACTION.'&path='.$tmp;?>'">
		<td colspan="4">
			<table><tr><td><a href="<?php echo $RootMain.$ACTION.'&path='.$tmp;?>"><img src="<?php echo $RootAdmin;?>/design/iskin/images/dirup.gif"></a></td><td>Наверх</td></tr></table>
		</td>
	</tr>
<?php
	}
	$i=0;
$Folders = array_reverse($Folders);
	foreach ($Folders as $value)
	{
?>
	<tr class="vmtable"  bgcolor="<?php echo ($i%2? '#eeeeee':'#dddddd');?>" id="R<?php echo $i; ?>"  onmouseover="FBA('R<?php echo $i; ?>');" onmouseout="FBP('R<?php echo $i; ?>');">
		<td onclick="javascript:window.location='<?php echo $RootMain.$ACTION.'&path='.($PATH?$PATH.'/':'').urlencode($value);?>'">
			<a href="<?php echo $RootMain.$ACTION.'&path='.($PATH?$PATH.'/':'').urlencode($value);?>"><img src="<?php echo $RootAdmin;?>design/iskin/images/folder.gif"></a>
		</td>
		<td width="100%" onclick="javascript:window.location='<?php echo $RootMain.$ACTION.'&path='.($PATH?$PATH.'/':'').urlencode($value);?>'">
			<?php echo $value;?>
		</td>
		<?php if ($_SESSION['D']  && $AG) { ?>
		<td>
			<a href="javascript:Rename(<?php echo "'".$value."'"?>);">
				<img src="<?php echo $RootAdmin;?>/design/iskin/images/edit2.gif" alt="Переименовать" alt="Переименовать">
			</a>
		</td>
		<td>
			<a href="javascript:DeleteFolder('/<?php echo urldecode($PATH?$PATH.'/':'').$value?>');">
				<img src="<?php echo $RootAdmin;?>/design/iskin/images/delete.gif" >
			</a>
		</td>
		<?php } ?>
	</tr>
	<tr class="trspacer">
		<td>
		</td>
	</tr>
<?php
	$i++;
	}
?>
</table>
<?php if (1) { ?>
<br>
<table style="border-width:1px;border-style:solid;border-color:#eeeeee;width:70%" cellpadding="0" cellspacing="0" >
<tr>
	<td colspan="5">
		Файлы
	</td>
</tr>
<?php if ($_SESSION['U']  && $AG) { ?>
<tr>
		<td colspan="5">
			<table style="text-align:center;border-width:1px;border-style:solid;border-color:#eeeeee;width:100%">
				<tr>
					<td>
						<span style="padding-left:5px">
						<input type="file" method="post" enctype="multipart/form-data"  size="1000" name="File" style="width:200px">
						</span>
						<input type="button" value="Загрузить" onclick="javascript:Upload();">
					</td>
				</tr>
			</table>
		</td>
</tr>
<?php } ?>
<tr class="itable_head">
<?php if ($_SESSION['D']  && $AG) { ?>
		<td align="left">
			<input type="checkbox" name="AllCheck" onclick="CheckAll();">
		</td>
	<?php } ?>
		<td>
		</td>
		<td width="100%">
			Файл
		</td>
		<td>
			&nbsp;&nbsp;Дата&nbsp;&nbsp;
		</td>
		<td>
			&nbsp;&nbsp;Размер&nbsp;&nbsp;
		</td>
	<td></td>	
		<td>
		</td>
	</tr>
	<tr class="trspacer">
		<td>
		</td>
	</tr>
<?php
//Files
	$PATH=urldecode($PATH);
	$OutP=FilterArray('{\.doc|\.docx|\.txt|\.rtf|\.odt}i',$Files);
$OutP = array_reverse($OutP);
	$i=0;
	foreach ($OutP as $value)
	{
		$URL=$RootMain.'files/'.$POSTFIX.str_replace('+','%20',urlencode(($PATH?$PATH.'/':'').$value));
		$URL=str_replace('%2F','/',$URL);
?>
	<tr align="center" class="vmtable"  bgcolor="<?php echo ($i%2? '#eeeeee':'#dddddd');?>" id="RR<?php echo $i; ?>"  onmouseover="FBA('RR<?php echo $i; ?>');" onmouseout="FBP('RR<?php echo $i; ?>');">
	<?php if ($_SESSION['D']  && $AG) { ?>
		<td align="left">
			<input type="checkbox" name="<?php echo urlencode($PATH.'/'.str_replace('.','\'',$value)); ?>">
		</td>
	<?php } ?>
		<td  onclick="javascript:window.location='<?php echo $URL?>'">
			<img src="<?php echo $RootAdmin;?>/design/iskin/images/doc.gif" >
		</td>
		<td onclick="javascript:window.location='<?php echo $URL;?>'">
			<?php echo $value; @ print_r($fls_lst);?>
		</td>

	        <td onclick="javascript:window.location='<?php echo $URL;?>'">
			<?php echo date("j.m.y H:i", filemtime($value));// edited by unrealm & TyWkaH?>
		</td>
		<td align="center" onclick="javascript:window.location='<?php echo $URL;?>'">
		<?php echo ceil(filesize($DirectoryRoot.'files/'.$POSTFIX.($PATH?$PATH.'/':'').$value)/1024). ' <br/>Kb';?>
		</td>
		<?php if ($_SESSION['D']  && $AG) { ?>
<td>
			<a href="javascript:Rename(<?php echo "'".$value."'"?>);">
				<img src="<?php echo $RootAdmin;?>/design/iskin/images/edit2.gif" alt="Переименовать" alt="Переименовать">
			</a>
		</td>
		<td>
			<a href="javascript:Delete('<?php echo str_replace('/','',$value)?>');")">
				<img src="<?php echo $RootAdmin;?>/design/iskin/images/delete.gif" >
			</a>
		</td>
		<?php } ?>
	</tr>
	<tr class="trspacer">
		<td>
		</td>	
	</tr>
<?php
	$i++;
	}
	$OutX=FilterArray('{\.xls|\.ods}i',$Files);
	foreach ($OutX as $value)
	{
	$URL=$RootMain.'files/'.$POSTFIX.str_replace('+','%20',urlencode(($PATH?$PATH.'/':'').$value));
	$URL=str_replace('%2F','/',$URL);
?>
	<tr class="vmtable"  bgcolor="<?php echo ($i%2? '#eeeeee':'#dddddd');?>" id="RRX<?php echo $i; ?>"  onmouseover="FBA('RRX<?php echo $i; ?>');" onmouseout="FBP('RRX<?php echo $i; ?>');">
	<?php if ($_SESSION['D']  && $AG) { ?>
		<td align="left">
			<input type="checkbox" name="<?php echo $PATH.'/'.str_replace('.','\'',$value); ?>">
		</td>
	<?php } ?>
		<td align="center" onclick="javascript:window.location='<?php echo $URL;?>'">
			<img src="<?php echo $RootAdmin;?>/design/iskin/images/excel.gif" >
		</td>
		<td onclick="javascript:window.location='<?php echo $URL;?>'">
			<?php echo $value;?>
		</td>
	        <td align="center" nclick="javascript:window.location='<?php echo $URL;?>'">
			<?php echo date("j.m.y H:i", filectime($value));// edited by unrealm & TyWkaH?>
		</td>
		<td align="center" onclick="javascript:window.location='<?php echo $URL;?>'">
		<?php echo ceil(filesize($DirectoryRoot.'files/'.$POSTFIX.($PATH?$PATH.'/':'').$value)/1024). ' <br/>Kb';?>
		</td>
		<?php if ($_SESSION['D']  && $AG) { ?>
<td>
			<a href="javascript:Rename(<?php echo "'".$value."'"?>);">
				<img src="<?php echo $RootAdmin;?>/design/iskin/images/edit2.gif" alt="Переименовать" alt="Переименовать">
			</a>
		</td>
		<td>
			<a href="javascript:Delete('<?php echo str_replace('/','',$value);?>');")">
				<img src="<?php echo $RootAdmin;?>/design/iskin/images/delete.gif" >
			</a>
		</td>
		<?php } ?>
	</tr>
	<tr class="trspacer">
		<td>
		</td>	
	</tr>
<?php
	$i++;
	}
	$OutA=FilterArray('{\.rar|\.zip|\.gzip&|\.jar|\.jad}i',$Files);
	foreach ($OutA as $value)
	{
	$URL=$RootMain.'files/'.$POSTFIX.str_replace('+','%20',urlencode(($PATH?$PATH.'/':'').$value));
	$URL=str_replace('%2F','/',$URL);
?>
	<tr class="vmtable"  bgcolor="<?php echo ($i%2? '#eeeeee':'#dddddd');?>" id="RRA<?php echo $i; ?>"  onmouseover="FBA('RRA<?php echo $i; ?>');" onmouseout="FBP('RRA<?php echo $i; ?>');">
	<?php if ($_SESSION['D']  && $AG) { ?>
		<td align="left">
			<input type="checkbox" name="<?php echo $PATH.'/'.str_replace('.','\'',$value); ?>">
		</td>
		<?php } ?>
		<td align="center" onclick="javascript:window.location='<?php echo $URL;?>'">
			<img src="<?php echo $RootAdmin;?>/design/iskin/images/archive.gif" >
		</td>
		<td onclick="javascript:window.location='<?php echo $URL;?>'">
			<?php echo $value;?>
		</td>
	        <td onclick="javascript:window.location='<?php echo $URL;?>'">
			<?php echo date("j.m.y H:i", filectime($value));// edited by unrealm & TyWkaH?>
		</td>
		<td align="center" onclick="javascript:window.location='<?php echo $URL;?>'">
		<?php echo ceil(filesize($DirectoryRoot.'files/'.$POSTFIX.($PATH?$PATH.'/':'').$value)/1024). ' <br/>Kb';?>
		</td>
		<?php if ($_SESSION['D']  && $AG) { ?>
<td>
			<a href="javascript:Rename(<?php echo "'".$value."'"?>);">
				<img src="<?php echo $RootAdmin;?>/design/iskin/images/edit2.gif" alt="Переименовать" alt="Переименовать">
			</a>
		</td>
		<td>
			<a href="javascript:Delete('<?php echo str_replace('/','',$value);?>');")">
				<img src="<?php echo $RootAdmin;?>/design/iskin/images/delete.gif" >
			</a>
		</td>
		<?php } ?>
	</tr>
	<tr class="trspacer">
		<td>
		</td>	
	</tr>
<?php
	$i++;
	}
	$OutMisc=array_diff($Files,$OutA,$OutP,$OutX);
	foreach ($OutMisc as $value)
	{
	$URL=$RootMain.'files/'.$POSTFIX.str_replace('+','%20',urlencode(($PATH?$PATH.'/':'').$value));
	$URL=str_replace('%2F','/',$URL);
?>
	<tr class="vmtable"  bgcolor="<?php echo ($i%2? '#eeeeee':'#dddddd');?>" id="RRB<?php echo $i; ?>"  onmouseover="FBA('RRB<?php echo $i; ?>');" onmouseout="FBP('RRB<?php echo $i; ?>');">
	<?php if ($_SESSION['D']  && $AG) { ?>
		<td align="left">
			<input type="checkbox" name="<?php echo $PATH.'/'.str_replace('.','\'',$value); ?>">
		</td>
	<?php } ?>
		<td align="center" onclick="javascript:window.location='<?php echo $URL;?>'">
			<img src="<?php echo $RootAdmin;?>/design/iskin/images/document.gif" >
		</td>
		<td onclick="javascript:window.location='<?php echo $URL;?>'">
			<?php echo $value;?>
		</td>
	        <td onclick="javascript:window.location='<?php echo $URL;?>'">
			<?php echo date("j.m.y H:i", filectime($value));// edited by unrealm & TyWkaH?>
		</td>
		<td align="center" onclick="javascript:window.location='<?php echo $URL;?>'">
			<?php echo ceil(filesize($DirectoryRoot.'files/'.$POSTFIX.($PATH?$PATH.'/':'').$value)/1024). " <br/>Kb ";?>
		</td>
		<?php if ($_SESSION['D']  && $AG) { ?>
<td>
			<a href="javascript:Rename(<?php echo "'".$value."'"?>);">
				<img src="<?php echo $RootAdmin;?>/design/iskin/images/edit2.gif" alt="Переименовать" alt="Переименовать">
			</a>
		</td>
		<td>
			<a href="javascript:Delete('<?php echo str_replace('/','',$value);?>');">
				<img src="<?php echo $RootAdmin;?>/design/iskin/images/delete.gif" >
			</a>
		</td>
		<?php } ?>
	</tr>
	<tr class="trspacer">
		<td>
		</td>	
	</tr>
<?php
	$i++;
	}
	
?>
<input type="hidden" name="SMode" value="0">
<input type="hidden" name="ParameterID" value="0">
<?php if ($_SESSION['D']  && $AG) { ?>
	<tr bgcolor="#eeeeee" id="RRC<?php echo ++$i; ?>"  onmouseover="FBA('RRC<?php echo $i; ?>');" onmouseout="FBP('RRC<?php echo $i; ?>');" onclick="DeleteChecked();">
		<td colspan="5" style="padding-left:20px;cursor:pointer">
		<table>
				<tr>
					<td>
					</td>
					<td  >
						<img  src="<?php echo $RootAdmin.'design/iskin/images/delete.gif';?>" >
					</td>
					<td  >
						<span style="font-size:11;color:#777777">Удалить выбранные файлы</span>
					</td>
					<td>
					</td>
				</tr>
			</table>
		<td>
	</tr>
<?php } ?>
</table>
<?php } ?>
<br>
</form>
<br>
<?php
}
else
{
?>
Директория не существует.
<?php
}
}
fclose($log);
?>
