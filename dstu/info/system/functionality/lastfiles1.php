<?php 
$unspl = exec("perl /var/www/html/system/2.pl");
$files = split('!~!', $unspl);
?>
<table style="border-width:1px;border-style:solid;border-color:#eeeeee;width:70%" cellpadding="0" cellspacing="0" >
<tr>
	<td colspan="5">
		Файлы/папки
	</td>
</tr>

<tr class="itable_head">
		<td>
		</td>
		<td width="80%">
			Файл/папки
		</td>
		<td>
			&nbsp;&nbsp;Дата&nbsp;&nbsp;
		</td>
		<td>
			&nbsp;&nbsp;Время&nbsp;&nbsp;
		</td>
		
		<td>
		</td>
	</tr>
	<tr class="trspacer">
		<td>
		</td>
	</tr>
<?php
	$k = 0;
       foreach($files as $i){
       	       $k++;
	       list($date, $time, $path) = explode('|', $i);
	       $path = rtrim($path);
	       $URL = str_replace('%2F', '/', urlencode($path));
	       if($time != 'folder'){
		       $URL = str_replace('+', '%20', $URL);
	       }else{
		       $vidra = explode('/', $URL);
		       if(preg_match('/p(\d+)/', $vidra[1], $m)){
			       $URL = 'navigate'.$m[1].'&path='.implode('/', array_splice($vidra, 2));
		       }
	       }
	       
?>
	<tr align="center" class="vmtable"  bgcolor="<?php echo ($k%2 ? '#eeeeee':'#dddddd');?>" id="RR<?php echo $k; ?>">
		<td>
		</td>
		<td align="center" onclick="javascript:window.location='<?php echo $URL;?>'">
		<?php 
			echo array_pop(explode('/', $path)); 
		?>
		</td>

	        <td align="center" onclick="javascript:window.location='<?php echo $URL;?>'">
		<?php if($date != '00'){ echo $date;}else{ echo "---"; } ?>
		</td>
		<td align="center" onclick="javascript:window.location='<?php echo $URL;?>'">
		<?php if($time != 'folder'){ echo $time;}else{ echo "---"; } ?>
		</td>
		<td>
		</td>
	</tr>
	<tr class="trspacer">
		<td>
		</td>
	</tr>
<?php } ?>	
</table>
