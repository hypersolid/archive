<script src="/jquery-1.4.4.min.js" type="text/javascript"></script>
<h2>Реестр принятых к исполнению служебных записок</h2>
<br>
<b>Сегодня: {%php%} echo date('d-m-Y'); {%/php%}</b>
<br>
<form method="POST" action="{%$a|default:'/note'%}?act=search">
<table border="1">
<tr>
<td>Структурное подразделение</td>
<td>Номер служебной записки</td>
<td>Дата</td>
<td></td>
</tr>

<tr>
<td>
<select name="name_unit" style="width: 350px;">
<option selected value="all">Все</option>
{%foreach from=$units key=key item=item %}
<option value="{%$key%}">{%$item%}</option>
{%/foreach%}
</select>
</td>
<td>
<input type="text" name="incom" />
</td>
<td>С <input type="text" name="date_from" value="ДД-ММ-ГГГГ" onclick="if(this.value == 'ДД-ММ-ГГГГ'){ this.value='';}" /></td>
<td>по <input type="text" name="date_to" value="ДД-ММ-ГГГГ" onclick="if(this.value == 'ДД-ММ-ГГГГ'){ this.value='';}" /></td>
</tr>
</table>

<input type="submit" value="Найти">
</form><br />

{%if isset($a) %}
<a href="/admin/note_adm?act=add">Новая запись</a>
{%/if%}

<br />

<select name="year" onchange="for(i = 1; i < 13; i++) { $('#m_link'+i).attr('href', $('#m_link'+i).attr('href')+'&year='+this.value); }">
<option selected disabled>{%$year|default:'2011'%}</option>
<option value="2010">2010</option>
<option value="2011">2011</option> <!-- дЮ, ЩРН ПЕДЙНЯРМШИ ЦЮБМНЙНД -->
</select>&nbsp;
<a id="m_link1" href="{%$a|default:'/note'%}?act=search&month=1{%$year|string_format:"&year=%s"%}">Январь</a>&nbsp;
<a id="m_link2" href="{%$a|default:'/note'%}?act=search&month=2{%$year|string_format:"&year=%s"%}">Февраль</a>&nbsp;
<a id="m_link3" href="{%$a|default:'/note'%}?act=search&month=3{%$year|string_format:"&year=%s"%}">Март</a>&nbsp;
<a id="m_link4" href="{%$a|default:'/note'%}?act=search&month=4{%$year|string_format:"&year=%s"%}">Апрель</a>&nbsp;
<a id="m_link5" href="{%$a|default:'/note'%}?act=search&month=5{%$year|string_format:"&year=%s"%}">Май</a>&nbsp;
<a id="m_link6" href="{%$a|default:'/note'%}?act=search&month=6{%$year|string_format:"&year=%s"%}">Июнь</a>&nbsp;
<a id="m_link7" href="{%$a|default:'/note'%}?act=search&month=7{%$year|string_format:"&year=%s"%}">Июль</a>&nbsp;
<a id="m_link8" href="{%$a|default:'/note'%}?act=search&month=8{%$year|string_format:"&year=%s"%}">Август</a>&nbsp;
<a id="m_link9" href="{%$a|default:'/note'%}?act=search&month=9{%$year|string_format:"&year=%s"%}">Сентябрь</a>&nbsp;
<a id="m_link10" href="{%$a|default:'/note'%}?act=search&month=10{%$year|string_format:"&year=%s"%}">Октябрь</a>&nbsp;
<a id="m_link11" href="{%$a|default:'/note'%}?act=search&month=11{%$year|string_format:"&year=%s"%}">Ноябрь</a>&nbsp;
<a id="m_link12" href="{%$a|default:'/note'%}?act=search&month=12{%$year|string_format:"&year=%s"%}">Декабрь</a>&nbsp;
<br />
<table border="1">
<tr>
<td>#</td>
<td>Входящий номер</td>
<td>Дата</td>
<td>Название структурного подразделения</td>
<td>Дата регистрации в ВЦ</td>
<td>Исполнитель</td>
<td>Дата принятия к исполнению</td>
<td>Дата выполнения</td>
<td>Примечание</td>
</tr>
<!-- {%counter start=$lst_len direction=down%} -->
{%foreach from=$lst item=item%}
<tr {%if $item.date_exec!='-' %}bgcolor="#00FF00"{%elseif isset($item.overdue)%}bgcolor="#FF0000"{%/if%} >
<td>{%counter%}</td>
<td>{%$item.incom_n%}</td>
<td>{%$item.incom_d%}</td>
{%if isset($a) %}
<td>{%$item.name_unit%}<br /><small><a href="/admin/note_adm?act=del&id={%$item.id%}">Удалить</a>&nbsp;
<a href="/admin/note_adm?act=edit&id={%$item.id%}">Редактировать</a></small></td>
{%else%}
<td>{%$item.name_unit%}</td>
{%/if%}
<td>{%$item.incom_date%}</td>
<td>{%$item.exec%}</td>
<td>{%$item.date_recv%}</td>
<td>{%$item.date_exec%}</td>
<td>{%$item.descr%}</td>
</tr>
{%/foreach%}

</table>
