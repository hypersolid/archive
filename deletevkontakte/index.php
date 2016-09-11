<?php
//79044410176
//DXDCDV477
//http://vkontakte.ru/app2700794_2716687
$app_id = '2699651';
$scope = 'friends,photos,wall,offline';
$redirect = 'http://127.0.0.1/?';
$link = "http://api.vkontakte.ru/oauth/authorize?client_id=".$app_id."&scope=".$scope."&redirect_uri=".$redirect."&display=popup&response_type=token";
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!-- <html xmlns="http://www.w3.org/1999/xhtml"> -->
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ru" lang="ru">
<head>
<link rel="shortcut icon" type="image/x-icon" href="/images/favicon.ico">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<script type="text/javascript" src="/jquery.js"></script>
<script type="text/javascript" src="http://userapi.com/js/api/openapi.js?45"></script>
<script type="text/javascript" src="/fancybox/jquery.fancybox-1.3.4.pack.js"></script> 
<link rel="stylesheet" type="text/css" href="/fancybox/jquery.fancybox-1.3.4.css" media="screen" /> 
<link href="/css/new.css" rel="stylesheet" type="text/css"/>

<title>Удалиться из ВКонтакте онлайн, бесплатно.</title>
<meta name="description" content="Онлайн сервис для удаления аккаунта из контакта. Здесь можете удалить своих друзей, фотографии, записи на стене. А также скачать свои фотографии перед удалением." />
<meta name="keywords" content="вконтакте удаление, удаление вконтакте, удалить страницу вконтакте, удаление из контакта, скачать фотографии вконтакте, удалить друзей вконтакте, удалить стену вконтакте" />
</head>

<script type="text/javascript">
  VK.init({apiId: 2699559, onlyWidgets: true});

  $(document).ready(function() {
	var link = '<?=$link?>';
  	$("a.screenshot").fancybox();
	$.ajaxSetup({
	  async: false
	});
	params = window.location.hash.replace("#", "");
	if (params != '') {
		$('#connect').hide();
		api_call("friends_total", "friends");
		api_call("photos_total",  "photos");
		$('#friends_trigger').click(friends_click);
		$('#photos_trigger').click(photos_click);
	} else {
		$('#friends_trigger').attr("href",link);
		$('#photos_trigger').attr("href",link);
	};
  });


  function api_call(script, target) {
	$.get('/janitors/'+script+'.php?'+params, function(data) { $('#'+target).html(data); });
  };
  function recursive_api_call(script, target) {
	$.get('/janitors/'+script+'.php?'+params, function(data) {
		$('#'+target).html(data);
		if (data != '0'){
			recursive_api_call(script, target);
		} else {
			unblock_buttons();
		};
	});
  };

  function friends_click(e) {
	block_buttons();
	recursive_api_call("friends", "friends");
	e.preventDefault();
  };
  function photos_click(e) {
	block_buttons();
	recursive_api_call("photos", "photos");
	e.preventDefault();
  };

  function block_buttons(e) {
	$('#step2 .button').hide();
	$('#loader').show();
  };
  function unblock_buttons(e) {
	$('#loader').hide();
	$('#step2 .button').show();
  };
</script>

<body>

<div id="wrapper">
<div id="card_out">
<div id="card_in">

<div id="header">
	<div id="logo" class="fl">
	 	<a href="/"><img src="/images/logo.png" title="удаление из контакта" alt="удаление из контакта" /></a>
	</div>
	<div id="menu" class="fr">
		<h1>Удалить страницу вконтакте из своей жизни. Просто. Бесплатно. Навсегда.</h1>
	</div>
	<div class="cb"></div>
</div>
<div class="hr"></div>
<div id="content">


<div id="part_left" class="fl">
<div class="fl">
		<div class="fl"><h2 class="title">Как удалиться из контакта?</h2></div>
		<div class="fl">
			<div id="vk_like"></div>
			<script type="text/javascript">
				VK.Widgets.Like("vk_like", {type: "mini"});
			</script>
		</div>
		<div class="cb"></div>
</div>
<div class="cb"></div>

<div id="info">
Теперь удалить страницу вконтакте / vkontakte.ru <b>возможно</b>. 
<br/>
И для этого больше не нужно скачивать программы и отправлять смс-сообщения на короткие номера. 
Просто следуя подсказкам нашего сайта, Вы удалите свои фотографии, друзей, записи на стене.
Весь процесс удаления из вконтакте займет не более 5 минут.
</div>
<div class="hr"></div>
<h3>Шаг 1. Подключите наш сайт к своей странице вконтакте:</h3>
<div id="step1">
	<div class="fl">
				<ul>
					<li><del>смс на короткие номера</del></li>
					<li><del>платные программы, вирусы</del></li>
					<li><del>регистрация</del></li>
				</ul>
	</div>
	<div class="fl">
				<ul>
					<li><del>логин</del></li>
					<li><del>пароль</del></li>
					<li><del>спам</del></li>
				</ul>
	</div>
	<div class="fl">
	<a href="<?=$link?>" class="button" id="connect">Подключить</a>
	</div>
	<div class="cb"></div>
</div>
<div id="step2">
	<h3> Шаг 2. Автоматическое удаление друзей и фотографий:</h3>
	<div  class="fl">
		<a href="#" class="button" id="friends_trigger">Удалить друзей</a>
		<div class="spacer"></div>
		<div><span id="friends">?</span> друзей</div>
	</div>
	<div class="fl">
		<a href="#" class="button" id="photos_trigger">Удалить фотографии</a>
		<div class="spacer"></div>
		<div><span id="photos">?</span> фотографий</div>
	</div>
	<div class="fl">
		<a href="http://vkontakte.ru/app2700794_2716687" target="_blank" class="button">Очистить стену</a>
		<div class="spacer"></div>
		<div id="wall"></div>
	</div>
	<div class="cb"></div>
	<div id="loader" style="display:none">
		<div  class="fr">
			<img src="/images/loader.gif"/>
		</div>
	</div>
</div>

<h3>Шаг 3. Удалите Ваши личные данные со страницы.</h3>
<div id="step3">
	<a href="/images/b_photo.jpg" class="screenshot"><img src="/images/s_photo.jpg" title="Моя страница > Изменить фотографию > Удалить фотографию" alt="Моя страница > Изменить фотографию > Удалить фотографию"/></a>
	Удалите Вашу фотографию
	<br />
	<a href="/images/b_name.jpg" class="screenshot"><img src="/images/s_name.jpg" title="Моя страница > Мои настройки > Изменить имя" alt="Моя страница > Мои настройки > Изменить имя"/></a>
	Поменяйте имя и фамилию на "Роберт Паттинсон" или "Марго Фонтейн".
</div>

<h3>Шаг 4.  Поменяйте пароль вконтакте на:</h3>
	<a href="/images/b_password.jpg" class="screenshot"><img src="/images/s_password.jpg" title="как удалиться из контакта" alt="как удалиться из контакта"/></a>
	<input value="<?=uniqid().uniqid().uniqid()?>">
<h3>Шаг 5. Для завершения нажмите на баннер</h3>
<script type="text/javascript"><!--
google_ad_client = "ca-pub-2757095090042676";
/* deletevkontakte.ru */
google_ad_slot = "1406777776";
google_ad_width = 468;
google_ad_height = 60;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
<br/>
Вот и всё! Вы успешно удалили Вашу страничку в контакте.
</div>
<div id="part_right" class="fr">
<h2 class="title">Есть что сказать напоследок?</h2>
<div id="vk_comments"></div>
<script type="text/javascript">
VK.Widgets.Comments("vk_comments", {limit: 5, width: "270", attach: false});
</script>
</div>
<div class="cb"></div>
</div>
</div>
</div>
</div>
</body>
</html>
