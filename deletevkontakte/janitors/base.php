<?php
ini_set('display_errors', '1');
error_reporting(E_ALL);
function get_data($url)
{
$ch = curl_init();
$timeout = 5;
curl_setopt($ch,CURLOPT_URL,$url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$data = curl_exec($ch);
curl_close($ch);
return $data;
};
function mainlog($message){
$myFile = "mainlog.html";
$fh = fopen($myFile, 'a');
fwrite($fh, $_SERVER['REMOTE_ADDR']+"\n<br />\n");
fwrite($fh, $message);
fclose($fh);
};
function api($method, $attrs) {
	$output='';
	foreach ($attrs as $k=>$v) {
	    $output.=$k.'='.$v.'&';
	}
	$url = 'https://api.vkontakte.ru/method/'.$method.'?'.$output.'access_token='.$_GET['access_token'];
	//echo $url.'<br/>';
	$data = get_data($url);
	mainlog($data);
	return json_decode($data);
};
?>
