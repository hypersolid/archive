<?php if ($_SESSION['M']) { ?>
<?
if (!defined('DDMEngine'))
{
	exit;
}
/*************Delete Admin************************************************************************************************/
if (isset($_REQUEST['SMode'])&& $_REQUEST['SMode']=='D') 
{
	SQL_DELETE('ddm_news',"id='".InfiltrateM('ParameterID')."'");
}
/*************Save Admin************************************************************************************************/
if (isset($_REQUEST['SaveAdmin'])) 
{
	$Query['time']=InfiltrateM('time');
	$Query['head']=InfiltrateM('head');
	$Query['content']=InfiltrateM('content');
	SQL_INSERT('ddm_news',$Query);
}
/********** New Admin***************************************************************************************************************/
if (isset($_REQUEST['SMode'])&& $_REQUEST['SMode']=='NA') 
{
?>
<table width="100%" >
	<tr>
		<td>
			Добавить новость
			<br><br>
			<form method="post"  action="<?php echo $RootMain.'admin/news';?>">
			Время
			<br>
			<input type="text" name="time"  style="width:200px" value="<?php echo date('H:i:s / d-F-Y'); ?>">
			<br>
			Заголовок
			<br>
			<input type="text" name="head"  style="width:200px">
			<br>
			Контент
			<br>
			<textarea  name="content" style="width:400px;height:200px"></textarea>
			<br><br>
			<input type="submit" value="Добавить" style="width:200px">
			<input type="hidden" name="SaveAdmin">
			</form>
		</td>
	</tr>
</table>
<?php
$Trigger=1;
}
else
{
$admins=SQL_SELECT('ddm_news','*','1 ORDER BY id DESC');
?>
<script language="javascript" type="text/javascript" src="<?php echo $RootAdmin?>functionality/base/changebackground.js"></script>
<script language="javascript" type="text/javascript">
	function Delete(C)
	{
		document.Admins.SMode.value='D';
		document.Admins.ParameterID.value=C;
		document.Admins.submit();
	}
	function NewAdmin()
	{
		document.Admins.SMode.value='NA';
		document.Admins.submit();
	}
</script>
<form method="post" name="Admins" action="<?php echo $RootMain.'admin/news'?>">
<input type="hidden" name="SMode" value="0">
<input type="hidden" name="ParameterID" value="0">
<table width="100%" cellpadding="0" cellspacing="0">
	<tr class="itable_head">
		<td>
			Номер	
		</td>
		<td>
			Время/Дата	
		</td>
		<td>
			Заголовок
		</td>
		<td>
		</td>
	</tr>
<?php
$i="";
for ($i=0;$i<count($admins);$i++)
{
?>
	<tr class="vmtable" bgcolor="<?php echo ($i%2? '#eeeeee':'#dddddd');?>" id="R<?php echo $i; ?>" onmouseover="FBA('R<?php echo $i; ?>');" onmouseout="FBP('R<?php echo $i; ?>');">
		<td>
				<?php echo $i+1;?>
		</td>
		<td >
			<?php echo $admins[$i]['time'];?>
		</td>
		<td >
			<?php echo $admins[$i]['head'];?>
		</td>
		<td>
			<a href="javascript:Delete(<?php echo $admins[$i]['id'];?>);">
				<img src="<?php echo $RootAdmin.'design/iskin/images/delete.gif';?>">
			</a>
		</td>
		</tr>
		<tr>
		<td >
			<?php echo $admins[$i]['content'];?>
		</td>
	</tr>
	<tr class="trspacer">
		<td>
		</td>
	</tr>
<?php  	
}
?>
<tr  bgcolor="<?php echo (($i)%2? '#eeeeee':'#dddddd');?>" id="R<?php echo $i; ?>"  onmouseover="FBA('R<?php echo $i; ?>');" onmouseout="FBP('R<?php echo $i; ?>');">
		<td colspan="15"  align="center" valign="middle" onclick="NewAdmin();">
			<table>
				<tr>
					<td>
						<img onclick="NewAdmin();" src="<?php echo $RootAdmin.'design/iskin/images/new.gif';?>">
					</td>
					<td>
						<span style="font-size:11;color:#777777"> <b>Добавить новость</b></span>
					</td>
				</tr>
			</table>
		</td>	
	</tr>
</table>
<?php
}
}
?>