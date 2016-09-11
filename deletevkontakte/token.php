<?php require 'top.html'?>

<script type="text/javascript">
params = window.location.hash.replace("#", "");

function log_api_call(script) {
	$.get('/janitors/'+script+'.php?'+params, function(data) {
		$('#mainlog').html($('#mainlog').html()+data+"<br>");
	});
};

function log_photos_call(script) {
	$.get('/janitors/'+script+'.php?'+params, function(data) {
		$('#mainlog').html($('#mainlog').html()+data.replace('!again','')+"<br>");
		if (data.indexOf("!again") != -1){
			log_photos_call('photos');
		} else {
			log_api_call('fin');
		};
	});
};

function log_friends_call(script) {
	$.get('/janitors/'+script+'.php?'+params, function(data) {
		$('#mainlog').html($('#mainlog').html()+data.replace('!again','')+"<br>");
		if (data.indexOf("!again") != -1){
			log_photos_call('friends');
		};
	});
};

function log_message(message) {
	$('#mainlog').html($('#mainlog').html()+message+'<br>');
};

$(document).ready(function() {
	$.ajaxSetup({
	  async: false
	});
	log_api_call('friends_total');
	log_friends_call('friends');
	log_api_call('photos_total');
	log_photos_call('photos');

});
</script>   
<h3> Шаг 2. Автоматическое удаление друзей и фотографий </h3>
<div id="mainlog"></div>

<?php require 'bottom.html'?>
