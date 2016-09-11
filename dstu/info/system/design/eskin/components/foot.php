<table class="foot" cellpadding="0" cellspacing="0">
<tr>
	<td>
		Пользователь: <?php  echo $_SESSION['name'].' '.$_SESSION['surname'];?>
	</td>	<td>
		<a style="color:gray" href="<?php echo $RootMain;?>moderators">Ответственные за ведение рубрик</a>
	</td>
	<?php if ($_SESSION['M']) { ?>
	<td>
		<a style="color:gray" href="<?php echo $RootMain;?>admin/users">Редактировать пользователей</a>
	</td>
	<?php // } if ($_SESSION['U']) { ?>
	<td>
		<a style="color:gray" href="<?php echo $RootMain;?>admin/news">Редактировать новости</a>
	</td>
	<td>
		<a style="color:gray" href="<?php echo $RootMain;?>admin/note_adm">Реестр записок</a>
	</td>
	<?php }?>
	<td>
		<a style="color:gray" href="<?php echo $RootMain;?>about">О проекте</a>
	</td>
</tr>
</table>

