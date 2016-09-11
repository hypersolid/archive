<?php 
 if (!defined('DDMEngine'))
{
	exit;
}
$news=SQL_SELECT('ddm_news','*','1 ORDER BY id DESC');
?>
<table width="100%" cellpadding="0" cellspacing="0">

<?php
$i="";
for ($i=0;$i<count($news);$i++)
{
?>
	<tr >
		<td>
			<b><?php echo $news[$i]['head'];?></b>
		</td>
		<td>
			<i><?php echo $news[$i]['time'];?></i>
		</td>
	</tr>
	<tr>
		<td>
			<?php echo $news[$i]['content'];?>
		</td>
	</tr>
<?php  	
}
?>
</table>