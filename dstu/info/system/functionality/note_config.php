<?php
//ini_set('display_errors', E_ALL);

class Tpl{
	
	function __construct(){
		$dir = $_SERVER['DOCUMENT_ROOT'];
		define('SMARTY_DIR', $dir.'/libs/');
		require_once(SMARTY_DIR . 'Smarty.class.php');
		$this->smarty = new Smarty();
		$this->smarty->template_dir = $dir.'/tpl/';
		$this->smarty->compile_dir = $dir.'/tpl/t_c/';
		$this->smarty->config_dir = $dir.'/tpl/configs/';
		$this->smarty->cache_dir = $dir.'/tpl/cache/';
		$this->smarty->left_delimiter = '{%';
		$this->smarty->right_delimiter = '%}';
		//ini_set('display_errors', E_ALL);
		//header('Content-type: text/html; charset=utf-8');
	}
	
	function show($template = ''){
		if($this->smarty->template_exists($template.'.tpl')){
			$this->smarty->display($template.'.tpl');
			return TRUE;
		}else{
			return FALSE;
		}
	}

	function fetch($template){
		return ($this->smarty->template_exists($template.'.tpl') ? $this->smarty->fetch($template.'.tpl') : FALSE);
	}

	function assign($var, $content = ''){
		if(isset($var) && $content !== ''){
			$this->smarty->assign($var, $content);
		}elseif(isset($var)){
			$this->smarty->assign($var);
		}
	}

	
	
}

class Config{
	private $config = array(
		'encodign' => 'UTF-8',
		'host'	=> 'localhost',
		'user'	=> 'info',
		'pass'	=> 'infopasskoir',
		'db'	=> 'info',
		'table'	=> 'note',
		'table_u'	=> 'note_units'
	);

	function get_config($r = 'db'){
		return (isset($this->config[$r]) ? $this->config[$r] : NULL);
	}

//	function get_units(){
//		return $this->units;
//	}
	
	function is(&$var){
		return (isset($var) ? $var : NULL);
	}

	function pars_get_query(){
		$_GET = array();
		$query = array_pop(explode('?', $_SERVER['REQUEST_URI']));
		$query = explode('&', $query);
		foreach ($query as $it){
			$tmp = explode('=', $it);
			if(isset($tmp[1])){
				$_GET[$tmp[0]] = $tmp[1];
			}
			unset($tmp);
		}
		return $_GET;
	}
	
	function check_input($flist, &$arr){
		if(!is_array($flist)){
			return FALSE;
		}
		foreach ($flist as $key => $val){
			//echo "$key => $val : {$arr[$key]}<br>";
			if(empty($arr[$key])){ //|| !preg_match("/^{$val}$/u", $arr[$key])){
				return FALSE;
			}
			$arr[$key] = trim($arr[$key]);
		}
		
		return TRUE;
	}
}

class Db extends Config{
	private $db;
	private $query = '';
	private $units = array();
	
	function __construct(){
		$this->db = mysql_connect($this->get_config('host'), $this->get_config('user'), $this->get_config('pass'));
		if(!$this->db){
			die('Couldn\'t to connect.');
		}
		
		if(!mysql_select_db($this->get_config('db'), $this->db)){
			die("Couldn't select db {$this->get_config('db')}");
		}
		/*$this->custom_query('SELECT * FROM note_units');
		$this->units = $this->st();
		$tmp = array();
		foreach($this->units as $item){
			$tmp[$item['id']] = $item['name'];
		}
		$this->units = $tmp;*/
	}
	
	function get_unit($name){
		return (isset($this->units[$name]) ? $this->units[$name] : FALSE);
	}
	
	function get_units(){
		$this->custom_query('SELECT * FROM note_units');
		$this->units = $this->st();
		$tmp = array();
		foreach($this->units as $item){
			$tmp[$item['id']] = $item['name'];
		}
		$this->units = $tmp;
		
		return $this->units;
	}
	
	function clear(){
		unset($this->query);
	}
	
	function custom_query($q){
		$this->query = $q;
	}
	
	function st(){
		$ret = array();
		//echo $this->query.'<br>';
		if($this->query == ''){
			return FALSE;
		}
		$result = mysql_query($this->query);
		if($result === FALSE){ // || (mysql_num_rows($result) == 0 && preg_match('/(select)/i', $this->query))){
			return FALSE;
		}
		if(preg_match('/(select)/i', $this->query) && mysql_num_rows($result) != 0){
			while ($row = mysql_fetch_assoc($result)) {
				array_push($ret, $row);
			}
			mysql_free_result($result);
		}
		
		$this->clear();
		return $ret;
	}
	
	function select($wh = '*'){
		$table = $this->get_config('table');
		$this->query = sprintf('SELECT %s FROM `%s` ', $wh, $table);
	}
	
	function select_where($where, $wh = '*'){
		$this->select($wh);
		$this->query .= sprintf('WHERE %s', $where);
	}
	
	function update($inf){
        	$this->query = "UPDATE `".$this->get_config('table').'` SET ';
        	foreach ($inf as $key => $val){
        		$this->query .= "`$key`='$val',";
        	}
        	$this->query = rtrim($this->query, ',');
	}
	
	function where($wh){
		$this->query .= sprintf(' WHERE %s', $wh);
	}
	
	function insert($inf){
		$keys = array();
        	$values = array();
        	$this->query = "INSERT INTO `".$this->get_config('table').'` ';
        	foreach ($inf as $key => $val){
                	array_push($keys, "`$key`");
                	array_push($values, "'$val'");
        	}
        	$this->query .= '('.implode(', ', $keys).') ';
        	$this->query .= 'VALUES('.implode(', ', $values).')';
	}
	
	function delete($wh){
		$this->custom_query('DELETE FROM `'.$this->get_config('table').'` ');
		$this->where($wh);
	}
	
}


?>
