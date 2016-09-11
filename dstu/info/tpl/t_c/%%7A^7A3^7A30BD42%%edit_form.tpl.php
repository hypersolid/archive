<?php /* Smarty version 2.6.26, created on 2010-03-16 22:41:51
         compiled from edit_form.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('modifier', 'default', 'edit_form.tpl', 6, false),)), $this); ?>
Сегодня: <?php  echo date('d-m-Y');  ?>

<br>
<br>

<form method="POST" action="/admin/note_adm?act=<?php echo ((is_array($_tmp=@$this->_tpl_vars['act'])) ? $this->_run_mod_handler('default', true, $_tmp, 'add') : smarty_modifier_default($_tmp, 'add')); ?>
">
<?php if (isset ( $this->_tpl_vars['id'] )): ?><input type="hidden" name="id" value="<?php echo $this->_tpl_vars['id']; ?>
"><?php endif; ?>
<p>Входящий номер: <input type="text" name="incom_n" value="<?php echo $this->_tpl_vars['incom_n']; ?>
" />&nbsp;
Дата: <input type="text" name="incom_d" value="<?php echo $this->_tpl_vars['incom_d']; ?>
" /></p>
<p>Название структурного подразделения: 
<select name="name_unit" style="width: 300px;">
<?php $_from = $this->_tpl_vars['units']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['key'] => $this->_tpl_vars['item']):
?>
	<option value="<?php echo $this->_tpl_vars['key']; ?>
" <?php if ($this->_tpl_vars['item'] == $this->_tpl_vars['name_unit']): ?>selected<?php endif; ?>><?php echo $this->_tpl_vars['item']; ?>
</option>
<?php endforeach; endif; unset($_from); ?>
</select>
</p>
<p>Дата получения: <input type="text" name="incom_date" value="<?php echo ((is_array($_tmp=@$this->_tpl_vars['incom_date'])) ? $this->_run_mod_handler('default', true, $_tmp, 'ДД-ММ-ГГГГ') : smarty_modifier_default($_tmp, 'ДД-ММ-ГГГГ')); ?>
" /></p>
<p>Исполнитель: <input type="text" name="exec" value="<?php echo ((is_array($_tmp=@$this->_tpl_vars['exec'])) ? $this->_run_mod_handler('default', true, $_tmp, '-') : smarty_modifier_default($_tmp, '-')); ?>
" /></p>
<p>Дата принятия к исполнению: <input type="text" name="date_recv" value="<?php echo ((is_array($_tmp=@$this->_tpl_vars['date_recv'])) ? $this->_run_mod_handler('default', true, $_tmp, '-') : smarty_modifier_default($_tmp, '-')); ?>
" /></p>
<p>Дата выполнения: <input type="text" name="date_exec" value="<?php echo ((is_array($_tmp=@$this->_tpl_vars['date_exec'])) ? $this->_run_mod_handler('default', true, $_tmp, '-') : smarty_modifier_default($_tmp, '-')); ?>
" /></p>
<p>Примечание: </p>
<textarea name="descr" cols="60" rows="20">
<?php echo ((is_array($_tmp=@$this->_tpl_vars['descr'])) ? $this->_run_mod_handler('default', true, $_tmp, '-') : smarty_modifier_default($_tmp, '-')); ?>

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
<?php $_from = $this->_tpl_vars['units']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['key'] => $this->_tpl_vars['item']):
?>
	<option value="<?php echo $this->_tpl_vars['key']; ?>
"><?php echo $this->_tpl_vars['item']; ?>
</option>
<?php endforeach; endif; unset($_from); ?>
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