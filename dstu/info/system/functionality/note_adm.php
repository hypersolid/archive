<?php
ini_set('display_errors', E_ALL);

require_once($_SERVER['DOCUMENT_ROOT'].'/system/functionality/note_config.php');

$db = new Db();
$tpl = new Tpl();
$_GET = $db->pars_get_query();
$flist = array(
	'incom_n'	=> '.+',
	'incom_d'	=> '.+',
	'name_unit' => '(\d)+',
	'incom_date'=> '((\d{1,2}-\d{1,2}-\d{4})|-|now)',
	'exec'		=> '.*',
	'date_recv'	=> '((\d{1,2}-\d{1,2}-\d{4})|-|now)',
	'date_exec'	=> '((\d{1,2}-\d{1,2}-\d{4})|-|now)',
	'descr'		=> '.*'
);

if ($_SESSION['M']) {
	move();
}

function move(){
	global $tpl, $db, $flist, $_GET;

	$tpl->assign('a', '/admin/note_adm');
	$tpl->assign('units', $db->get_units());
	$_GET['act'] = (isset($_GET['act']) ? $_GET['act'] : 'lol');
	switch ($_GET['act']){
		case 'add': add(); break;
		case 'del': del(); break;
		case 'edit':edit();break;
		case 'edit_unit':edit_unit();break;
		default: lst();
	}
}

function edit_unit(){
		global $tpl, $db, $flist, $_GET;
		
		if(isset($_POST['uact'])){
			if($_POST['uact'] == 'edit' && !empty($_POST['new_name_unit'])){
				$_POST['new_name_unit'] = mysql_real_escape_string($_POST['new_name_unit']);
				$db->custom_query("UPDATE `note_units` SET `name`='{$_POST['new_name_unit']}' WHERE `id`=".intval($_POST['name_unit']));
				$db->st();
			}elseif($_POST['uact'] == 'del'){
				$db->custom_query("DELETE FROM `note_units` WHERE `id`=".intval($_POST['name_unit']));
				$db->st();
			}
			unset($_GET['act']);
			move();
			//header("Location: http://info.dstu.local/admin/note_adm");
		}
		
		lst();
}

function add(){
		global $tpl, $db, $flist, $_GET;
		
		if(isset($_POST['new_name_unit'])){
			$_POST['new_name_unit'] = mysql_real_escape_string($_POST['new_name_unit']);
			$db->custom_query("INSERT INTO note_units (`name`) VALUES ('{$_POST['new_name_unit']}')");
			$db->st();
			unset($_GET['act']);
			move();
			//header("Location: http://info.dstu.local/admin/note_adm");
		}
		
		if(!$db->check_input($flist, $_POST)){
			$tpl->show('edit_form');
		}else{
			foreach ($flist as $key => $val){
				$inf[$key] = $_POST[$key];
				if(preg_match('/date/', $key)){
					$inf[$key] = ($inf[$key] == '' ? '' : $inf[$key]);
					$inf[$key] = ($inf[$key] == 'now' ? date('Y-m-d') : $inf[$key]);
					if(preg_match('/^(\d{1,2})-(\d{1,2})-(\d{4})$/', $inf[$key], $m)){
						$inf[$key] = date('Y-m-d', strtotime("{$m[3]}-{$m[2]}-{$m[1]}"));
					}

				}
				$inf['incom'] = "{$_POST['incom_n']}&{$_POST['incom_d']}";
				$inf['name_unit'] = $db->get_unit((int)$_POST['name_unit']);
				unset($inf['incom_d']); unset($inf['incom_n']);
			}
			
			$db->insert($inf);
			if($db->st() !== FALSE){
				echo "Ok!<br>";
				unset($_GET);
				move();
			}
		}
}

function edit(){
	global $tpl, $db, $flist, $_GET;
	
	if($db->check_input($flist, $_POST) && !empty($_POST['id']) && preg_match('/^\d+$/', $_POST['id'])){
		foreach ($flist as $key => $val){
			$inf[$key] = $_POST[$key];
			if(preg_match('/date/', $key)){
				$inf[$key] = ($inf[$key] == '' ? '' : $inf[$key]);
				$inf[$key] = ($inf[$key] == 'now' ? date('Y-m-d') : $inf[$key]);
				if(preg_match('/^(\d{1,2})-(\d{1,2})-(\d{4})$/', $inf[$key], $m)){
					$inf[$key] = date('Y-m-d', strtotime("{$m[3]}-{$m[2]}-{$m[1]}"));
				}
			}
			$inf['incom'] = "{$_POST['incom_n']}&{$_POST['incom_d']}";
			$inf['name_unit'] = $db->get_unit((int)$_POST['name_unit']);
			unset($inf['incom_d']); unset($inf['incom_n']);
		}
			
		$db->update($inf);
		$db->where('id='.(int)$_POST['id']);
		if($db->st() !== FALSE){
			echo "Ok!";
			unset($_GET);
			move();
		}
	}elseif(!empty($_GET['id']) && preg_match('/^\d+$/', $_GET['id'])){
		$db->select_where('id='.$_GET['id']);
		$r = $db->st();
		if($r !== FALSE){
			foreach ($r[0] as $key => $val){
				if(preg_match('/date/', $key)){
					$r[0][$key] = implode('-', array_reverse(explode('-', array_shift(explode(' ', $r[0][$key])))));
					if(preg_match('/0{4}/', $r[0][$key])){
						$r[0][$key] = '-';
					}
				}
			}
			!empty($r[0]['incom']) ? $tmp = explode('&', $r[0]['incom']) : '';
			$tpl->assign($r[0]);
			$tpl->assign(array('incom_n' => $tmp[0], 'incom_d' => $tmp[1]));
			$tpl->assign('act', 'edit');
			$tpl->assign('id', (int)$_GET['id']);
			$tpl->show('edit_form');
		}else{
			echo 'Error';
		}
	}else{
		lst();
	}
}

function del(){
	global $tpl, $db, $_GET;
	
	if(!empty($_GET['id']) && preg_match('/^\d+$/', $_GET['id'])){
		$db->delete("id={$_GET['id']}");
		if($db->st() !== FALSE){
			echo "Ok!";
			unset($_GET);
			move();
		}
	}else{
		lst();
	}
}

function lst(){
	global $tpl, $db, $_GET;

	if($db->is($_GET['act']) === 'search'){
		if(intval($_GET['month'])){
			if( ! isset($_GET['year']) || ! intval($_GET['year'])){
				$_GET['year'] = '-';
			}else{
				$tpl->assign('year', $_GET['year']);
			}
			$p1 = (intval($_GET['year']) ? intval($_GET['year']) : 'Y').'-'.sprintf('%02d', intval($_GET['month'])).'-01';
			$_POST['date_from'] = date($p1);
			$p1 = (intval($_GET['year']) ? intval($_GET['year']) : 'Y').'-'.sprintf('%02d', intval($_GET['month'])).'-t';
			$_POST['date_to'] = date($p1, strtotime($_POST['date_from']));
			$db->custom_query('SELECT * FROM 
`'.$db->get_config('table')."` WHERE incom_date >= 
'{$_POST['date_from']}' AND incom_date <= '{$_POST['date_to']}' ORDER BY 
incom_date desc");
		}elseif(isset($_POST['name_unit']) && ($u = $db->get_unit($_POST['name_unit']))){
			$db->custom_query('SELECT * FROM 
`'.$db->get_config('table')."` WHERE name_unit='{$u}' ORDER BY 
incom_date desc LIMIT 25");
		}elseif(!empty($_POST['incom'])){
			$_POST['incom'] = mysql_real_escape_string($_POST['incom']);
			$db->custom_query('SELECT * FROM 
`'.$db->get_config('table')."` WHERE incom LIKE '%{$_POST['incom']}%' 
ORDER BY incom_date desc LIMIT 25");
		}elseif(isset($_POST['date_from']) && isset($_POST['date_to']) && 
			$db->check_input(array('date_from' => '\d{1,2}-\d{1,2}-\d{4}', 'date_to' => '\d{1,2}-\d{1,2}-\d{4}'), $_POST)){
			preg_match('/^(\d{1,2})-(\d{1,2})-(\d{4})$/', $_POST['date_from'], $m);
			$_POST['date_from'] = date("Y-m-d", strtotime("{$m[3]}-{$m[2]}-{$m[1]}"));
			preg_match('/^(\d{1,2})-(\d{1,2})-(\d{4})$/', $_POST['date_to'], $m);
			$_POST['date_to'] = date("Y-m-d", strtotime("{$m[3]}-{$m[2]}-{$m[1]}"));
			$db->custom_query('SELECT * FROM 
`'.$db->get_config('table')."` WHERE incom_date >= 
'{$_POST['date_from']}' AND incom_date <= '{$_POST['date_to']}' ORDER BY 
incom_date desc LIMIT 50");
		}else{
			$db->custom_query('SELECT * FROM 
`'.$db->get_config('table').'` ORDER BY incom_date desc LIMIT 25');
		}
	}else{
		$db->custom_query('SELECT * FROM 
`'.$db->get_config('table').'` ORDER BY incom_date desc LIMIT 25');
	}

	$r = $db->st();
	if($r !== FALSE && !empty($r[0])){
		for($i=0; $i < count($r); $i++){
			foreach ($r[$i] as $key => $val){
				if(preg_match('/date/', $key)){
					$r[$i][$key] = implode('-', array_reverse(explode('-', array_shift(explode(' ', $r[$i][$key])))));
					if(preg_match('/0{4}/', $r[$i][$key])){
						$r[$i][$key] = '-';
					}
					if($r[$i]['date_exec'] == '-' && $r[$i]['date_recv'] != '-' && strtotime('-2 week')-strtotime($r[$i]['date_recv']) > 0){
						$r[$i]['overdue'] = TRUE;
					}
				}
			}
			list($r[$i]['incom_n'], $r[$i]['incom_d']) = explode('&', $r[$i]['incom']);
		}
		$tpl->assign('lst', $r);
		$tpl->assign('lst_len', count($r)+1);
	}
	$tpl->show('list');
}

?>
