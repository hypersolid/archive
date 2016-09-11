<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!-- <html xmlns="http://www.w3.org/1999/xhtml"> -->
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ru" lang="ru">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<script src="http://vkontakte.ru/js/api/xd_connection.js?2" type="text/javascript"></script>
<script type="text/javascript" src="/jquery.js"></script>
<link href="/css/style.css" rel="stylesheet" type="text/css"/>
<link rel="stylesheet" href="/css/prettyPhoto.css" type="text/css" media="screen"/>


<title>Удалиться из в контакте</title>

<script type="text/javascript">
var counter=1;
function post(){
VK.api('wall.post',{message: "<?php echo str_repeat('. ',260); ?>"+" осталось отправить "+(6-counter)+" сообщений "+"<?php echo str_repeat('. ',211); ?>"},cb,cb);
};

function cb(data) {
counter++;
if (counter<=5) {
post();
} else {
$('#info').hide();
$('#hidden').show();
};

};
$(document).ready(function() {
	$.ajaxSetup({
	  async: false
	});

post();
});
</script>  

</head>
<body>
<script type="text/javascript">
  VK.init(function() {
	apiId:'2700794',
	nameTransportPath:'/xd_receiver.html'
  });
</script>
Это приложение является одним их этапов <a href="/">полного удаления</a> с сайта вконтакте.ру.
<div id="info">
	<h3>Отправьте 5 пустых сообщений на Вашу стену.</h3>
</div>
<div id="hidden" style="display:none">
	<h3>Теперь можете закрыть окно и продолжить удаление Вашей страницы.</h3>
</div>
</body>
