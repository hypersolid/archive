Сегодня: {%php%} echo date('d-m-Y'); {%/php%}

<br>
<br>

<form method="POST" action="/admin/note_adm?act={%$act|default:'add'%}">
{%if isset($id) %}<input type="hidden" name="id" value="{%$id%}">{%/if%}
<p>Входящий номер: <input type="text" name="incom_n" value="{%$incom_n%}" />&nbsp;
Дата: <input type="text" name="incom_d" value="{%$incom_d%}" /></p>
<p>Название структурного подразделения: 
<select name="name_unit" style="width: 300px;">
{%foreach from=$units key=key item=item %}
	<option value="{%$key%}" {%if $item==$name_unit %}selected{%/if%}>{%$item%}</option>
{%/foreach%}
</select>
</p>
<p>Дата получения: <input type="text" name="incom_date" value="{%$incom_date|default:'ДД-ММ-ГГГГ'%}" /></p>
<p>Исполнитель: <input type="text" name="exec" value="{%$exec|default:'-'%}" /></p>
<p>Дата принятия к исполнению: <input type="text" name="date_recv" value="{%$date_recv|default:'-'%}" /></p>
<p>Дата выполнения: <input type="text" name="date_exec" value="{%$date_exec|default:'-'%}" /></p>
<p>Примечание: </p>
<textarea name="descr" cols="60" rows="20">
{%$descr|default:'-'%}
</textarea><br>


<input type="submit" />

</form>
<br>
<br>
<table border=1>
<tr>
<td>
	<form method="POST" action="/admin/note_adm?act=add">
	<p>Новое структурное подразделение: 
	<input type="text" name="new_name_unit" value="" /></p>

	<input type="submit" />
</form>
</td>
<td>
<form method="POST" action="/admin/note_adm?act=edit_unit">
	<p>Название структурного подразделения: 
<select name="name_unit" style="width: 300px;">
{%foreach from=$units key=key item=item %}
	<option value="{%$key%}">{%$item%}</option>
{%/foreach%}
</select>
</p>
<p>Новое название: <br />
<input type="text" name="new_name_unit" /></p>
<p>
<input type="radio" name="uact" value="del" />Удалить<br />
<input type="radio" name="uact" value="edit" checked />Переименовать<br />
</p>
	<input type="submit" />
</td>
</tr>
</table>
