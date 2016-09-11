<?php /* Smarty version 2.6.26, created on 2011-01-17 13:03:49
         compiled from list.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'default', 'list.tpl', 6, false),array('modifier', 'string_format', 'list.tpl', 46, false),array('function', 'counter', 'list.tpl', 71, false),)), $this); ?>
<script src="/jquery-1.4.4.min.js" type="text/javascript"></script>
<h2>Реестр принятых к исполнению служебных записок</h2>
<br>
<b>Сегодня: <?php  echo date('d-m-Y');  ?></b>
<br>
<form method="POST" action="<?php echo ((is_array($_tmp=@$this->_tpl_vars['a'])) ? $this->_run_mod_handler('default', true, $_tmp, '/note') : smarty_modifier_default($_tmp, '/note')); ?>
?act=search">
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
<?php $_from = $this->_tpl_vars['units']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['key'] => $this->_tpl_vars['item']):
?>
<option value="<?php echo $this->_tpl_vars['key']; ?>
"><?php echo $this->_tpl_vars['item']; ?>
</option>
<?php endforeach; endif; unset($_from); ?>
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

<?php if (isset ( $this->_tpl_vars['a'] )): ?>
<a href="/admin/note_adm?act=add">Новая запись</a>
<?php endif; ?>

<br />

<select name="year" onchange="for(i = 1; i < 13; i++) { $('#m_link'+i).attr('href', $('#m_link'+i).attr('href')+'&year='+this.value); }">
<option selected disabled><?php echo ((is_array($_tmp=@$this->_tpl_vars['year'])) ? $this->_run_mod_handler('default', true, $_tmp, '2011') : smarty_modifier_default($_tmp, '2011')); ?>
</option>
<option value="2010">2010</option>
<option value="2011">2011</option> <!-- дЮ, ЩРН ПЕДЙНЯРМШИ ЦЮБМНЙНД -->
</select>&nbsp;
<a id="m_link1" href="<?php echo ((is_array($_tmp=@$this->_tpl_vars['a'])) ? $this->_run_mod_handler('default', true, $_tmp, '/note') : smarty_modifier_default($_tmp, '/note')); ?>
?act=search&month=1<?php echo ((is_array($_tmp=$this->_tpl_vars['year'])) ? $this->_run_mod_handler('string_format', true, $_tmp, "&year=%s") : smarty_modifier_string_format($_tmp, "&year=%s")); ?>
">Январь</a>&nbsp;
<a id="m_link2" href="<?php echo ((is_array($_tmp=@$this->_tpl_vars['a'])) ? $this->_run_mod_handler('default', true, $_tmp, '/note') : smarty_modifier_default($_tmp, '/note')); ?>
?act=search&month=2<?php echo ((is_array($_tmp=$this->_tpl_vars['year'])) ? $this->_run_mod_handler('string_format', true, $_tmp, "&year=%s") : smarty_modifier_string_format($_tmp, "&year=%s")); ?>
">Февраль</a>&nbsp;
<a id="m_link3" href="<?php echo ((is_array($_tmp=@$this->_tpl_vars['a'])) ? $this->_run_mod_handler('default', true, $_tmp, '/note') : smarty_modifier_default($_tmp, '/note')); ?>
?act=search&month=3<?php echo ((is_array($_tmp=$this->_tpl_vars['year'])) ? $this->_run_mod_handler('string_format', true, $_tmp, "&year=%s") : smarty_modifier_string_format($_tmp, "&year=%s")); ?>
">Март</a>&nbsp;
<a id="m_link4" href="<?php echo ((is_array($_tmp=@$this->_tpl_vars['a'])) ? $this->_run_mod_handler('default', true, $_tmp, '/note') : smarty_modifier_default($_tmp, '/note')); ?>
?act=search&month=4<?php echo ((is_array($_tmp=$this->_tpl_vars['year'])) ? $this->_run_mod_handler('string_format', true, $_tmp, "&year=%s") : smarty_modifier_string_format($_tmp, "&year=%s")); ?>
">Апрель</a>&nbsp;
<a id="m_link5" href="<?php echo ((is_array($_tmp=@$this->_tpl_vars['a'])) ? $this->_run_mod_handler('default', true, $_tmp, '/note') : smarty_modifier_default($_tmp, '/note')); ?>
?act=search&month=5<?php echo ((is_array($_tmp=$this->_tpl_vars['year'])) ? $this->_run_mod_handler('string_format', true, $_tmp, "&year=%s") : smarty_modifier_string_format($_tmp, "&year=%s")); ?>
">Май</a>&nbsp;
<a id="m_link6" href="<?php echo ((is_array($_tmp=@$this->_tpl_vars['a'])) ? $this->_run_mod_handler('default', true, $_tmp, '/note') : smarty_modifier_default($_tmp, '/note')); ?>
?act=search&month=6<?php echo ((is_array($_tmp=$this->_tpl_vars['year'])) ? $this->_run_mod_handler('string_format', true, $_tmp, "&year=%s") : smarty_modifier_string_format($_tmp, "&year=%s")); ?>
">Июнь</a>&nbsp;
<a id="m_link7" href="<?php echo ((is_array($_tmp=@$this->_tpl_vars['a'])) ? $this->_run_mod_handler('default', true, $_tmp, '/note') : smarty_modifier_default($_tmp, '/note')); ?>
?act=search&month=7<?php echo ((is_array($_tmp=$this->_tpl_vars['year'])) ? $this->_run_mod_handler('string_format', true, $_tmp, "&year=%s") : smarty_modifier_string_format($_tmp, "&year=%s")); ?>
">Июль</a>&nbsp;
<a id="m_link8" href="<?php echo ((is_array($_tmp=@$this->_tpl_vars['a'])) ? $this->_run_mod_handler('default', true, $_tmp, '/note') : smarty_modifier_default($_tmp, '/note')); ?>
?act=search&month=8<?php echo ((is_array($_tmp=$this->_tpl_vars['year'])) ? $this->_run_mod_handler('string_format', true, $_tmp, "&year=%s") : smarty_modifier_string_format($_tmp, "&year=%s")); ?>
">Август</a>&nbsp;
<a id="m_link9" href="<?php echo ((is_array($_tmp=@$this->_tpl_vars['a'])) ? $this->_run_mod_handler('default', true, $_tmp, '/note') : smarty_modifier_default($_tmp, '/note')); ?>
?act=search&month=9<?php echo ((is_array($_tmp=$this->_tpl_vars['year'])) ? $this->_run_mod_handler('string_format', true, $_tmp, "&year=%s") : smarty_modifier_string_format($_tmp, "&year=%s")); ?>
">Сентябрь</a>&nbsp;
<a id="m_link10" href="<?php echo ((is_array($_tmp=@$this->_tpl_vars['a'])) ? $this->_run_mod_handler('default', true, $_tmp, '/note') : smarty_modifier_default($_tmp, '/note')); ?>
?act=search&month=10<?php echo ((is_array($_tmp=$this->_tpl_vars['year'])) ? $this->_run_mod_handler('string_format', true, $_tmp, "&year=%s") : smarty_modifier_string_format($_tmp, "&year=%s")); ?>
">Октябрь</a>&nbsp;
<a id="m_link11" href="<?php echo ((is_array($_tmp=@$this->_tpl_vars['a'])) ? $this->_run_mod_handler('default', true, $_tmp, '/note') : smarty_modifier_default($_tmp, '/note')); ?>
?act=search&month=11<?php echo ((is_array($_tmp=$this->_tpl_vars['year'])) ? $this->_run_mod_handler('string_format', true, $_tmp, "&year=%s") : smarty_modifier_string_format($_tmp, "&year=%s")); ?>
">Ноябрь</a>&nbsp;
<a id="m_link12" href="<?php echo ((is_array($_tmp=@$this->_tpl_vars['a'])) ? $this->_run_mod_handler('default', true, $_tmp, '/note') : smarty_modifier_default($_tmp, '/note')); ?>
?act=search&month=12<?php echo ((is_array($_tmp=$this->_tpl_vars['year'])) ? $this->_run_mod_handler('string_format', true, $_tmp, "&year=%s") : smarty_modifier_string_format($_tmp, "&year=%s")); ?>
">Декабрь</a>&nbsp;
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
<!-- <?php echo smarty_function_counter(array('start' => $this->_tpl_vars['lst_len'],'direction' => 'down'), $this);?>
 -->
<?php $_from = $this->_tpl_vars['lst']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['item']):
?>
<tr <?php if ($this->_tpl_vars['item']['date_exec'] != '-'): ?>bgcolor="#00FF00"<?php elseif (isset ( $this->_tpl_vars['item']['overdue'] )): ?>bgcolor="#FF0000"<?php endif; ?> >
<td><?php echo smarty_function_counter(array(), $this);?>
</td>
<td><?php echo $this->_tpl_vars['item']['incom_n']; ?>
</td>
<td><?php echo $this->_tpl_vars['item']['incom_d']; ?>
</td>
<?php if (isset ( $this->_tpl_vars['a'] )): ?>
<td><?php echo $this->_tpl_vars['item']['name_unit']; ?>
<br /><small><a href="/admin/note_adm?act=del&id=<?php echo $this->_tpl_vars['item']['id']; ?>
">Удалить</a>&nbsp;
<a href="/admin/note_adm?act=edit&id=<?php echo $this->_tpl_vars['item']['id']; ?>
">Редактировать</a></small></td>
<?php else: ?>
<td><?php echo $this->_tpl_vars['item']['name_unit']; ?>
</td>
<?php endif; ?>
<td><?php echo $this->_tpl_vars['item']['incom_date']; ?>
</td>
<td><?php echo $this->_tpl_vars['item']['exec']; ?>
</td>
<td><?php echo $this->_tpl_vars['item']['date_recv']; ?>
</td>
<td><?php echo $this->_tpl_vars['item']['date_exec']; ?>
</td>
<td><?php echo $this->_tpl_vars['item']['descr']; ?>
</td>
</tr>
<?php endforeach; endif; unset($_from); ?>

</table>