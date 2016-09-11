// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function show_yellow_popup(name){
  popup = $('#'+name+'_popup');
  popup.show();
  target = parseInt(popup.css('left'));
  popup.css('left',target - 500);
  popup.animate({
      left:target
    },{
      easing: 'easeOutBounce',
      duration:500,
  });
};

function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".fields").hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).parent().before(content.replace(regexp, new_id));
}

function clearTimeouts() {
  if(typeof(timers) === "object"){
    for (var i= 0;i < timers.length; i++) {
      clearTimeout(timers[i]);
    }
  }
  timers = new Array();
}

// add commas separators to numbers: "1000" => "1,000"
function addCommas(nStr)
{
  nStr += '';
  x = nStr.split('.');
  x1 = x[0];
  x2 = x.length > 1 ? '.' + x[1] : '';
  var rgx = /(\d+)(\d{3})/;
  while (rgx.test(x1)) {
    x1 = x1.replace(rgx, '$1' + ',' + '$2');
  }
  return x1 + x2;
}


/* preLoadImages function */
/* http://engineeredweb.com/blog/09/12/preloading-images-jquery-and-javascript */
var cache = [];
// Arguments are image paths relative to the current page.
$.preLoadImages = function() {
  var args_len = arguments.length;
  for (var i = args_len; i--;) {
    var cacheImage = document.createElement('img');
    cacheImage.src = arguments[i];
    cache.push(cacheImage);
  }
}

// Zopim live chat
function init_live_chat(e){
  window.$zopim||(function(d,s){
    var z=$zopim=function(c){
      z._.push(c)
      },$=z.s=
    d.createElement(s),e=d.getElementsByTagName(s)[0];
    z.set=function(o){
      z.set.
      _.push(o)
      };
  
    z._=[];
    z.set._=[];
    $.async=!0;
    $.setAttribute('charset','utf-8');
    $.src='//cdn.zopim.com/?7ysDF8HHUBb9xGDGmIzdafw3ZGI1bCsS';
    z.t=+new Date;
    $.
    type='text/javascript';
    e.parentNode.insertBefore($,e)
  })(document,'script');

  $zopim(function() {
    $zopim.livechat.bubble.hide();
    $zopim.livechat.button.setPosition('br');
    $zopim.livechat.window.show();
  });

  e.preventDefault();
};

function init_dialog(selector, config){
  var $selector = $(selector);
  merged_config = $.extend({
    modal: true,
    autoOpen: false,
    draggable: false,
    resizable: false,
    closeText: '',
    open: function(){
      $('.ui-widget-overlay').bind('click',function(){
          $selector.dialog('close');
      });
    }
  }, config);
  $selector.dialog(merged_config);
};

function setDefaultValue(elem, val) {
  elem.val(val);
  elem.focus(function() {
    if($(this).val() == val) {
      $(this).val('');
    }
  });
  elem.blur(function() {
    if($(this).val() == '') {
      $(this).val(val);
    }
  });
};

function isValidEmailAddress(emailAddress) {
    var pattern = new RegExp(/^(("[\w-+\s]+")|([\w-+]+(?:\.[\w-+]+)*)|("[\w-+\s]+")([\w-+]+(?:\.[\w-+]+)*))(@((?:[\w-+]+\.)*\w[\w-+]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$)|(@\[?((25[0-5]\.|2[0-4][\d]\.|1[\d]{2}\.|[\d]{1,2}\.))((25[0-5]|2[0-4][\d]|1[\d]{2}|[\d]{1,2})\.){2}(25[0-5]|2[0-4][\d]|1[\d]{2}|[\d]{1,2})\]?$)/i);
    return pattern.test(emailAddress);
};

function notImplemented(e){
  alert('Not implemented yet');
  e.preventDefault;
};

/* Invite dialogs */
function reset_email_invites(){
  form = $('#email_invites_dialog .form');
  loader = $('#email_invites_dialog .loader');
  email1 = $('#email1');
  email2 = $('#email2');
  c = 'error';
  email1.removeClass(c);
  email2.removeClass(c);
  
  $('#email_invites_dialog .clean').val('');
  $('#email_invites_dialog .clean').blur();

  //$('#email_invites_dialog .wingman1').toggle($('#user_variables').data('invites_left') == '2');

  loader.hide();
  form.show();
};

function validate_email_invites(){
    email1 = $('#email1');
    email2 = $('#email2');

    if (!isValidEmailAddress(email1.val())){
      email1.addClass('error');
    } else {
      email1.removeClass('error');
    };
    if (!isValidEmailAddress(email2.val())){
      email2.addClass('error');
    } else { 
      email2.removeClass('error');
    };
};

function show_email_invite_dialog(){
  reset_email_invites();
  //$('#facebook_invites_dialog').dialog('close');
  $('#email_invites_dialog').dialog('open');
  $('#email_invites_dialog input').blur();
};

// function show_facebook_invite_dialog(){
//   $('#email_invites_dialog').dialog('close');
//   $('#facebook_invites_dialog').dialog('open');
// };

// Wingmen panel & Sent invites utility functions
function push_wingmen_panel(html){
  $('#user_variables').data('wingmen_panel', html);
};
function pop_wingmen_panel(html){
  if (!html) {
    html = $('#user_variables').data('wingmen_panel');
  };
  if (html && html != '') {
    $('#wingmen_highlight').fadeIn(100);
    $('#wingmen_panel').html(html);
    $('#wingmen_highlight').fadeOut(1800);
    $('#user_variables').data('wingmen_panel', '');
  }
};

function update_sent_invites_dialog(html){
  content = $('#invites_were_sent_dialog .content');
  loader = $('#invites_were_sent_dialog .loader');
  if (html != '') {
    content.html(html);
    loader.hide();
    content.show();
  } else {
    content.hide();
    loader.show();
  };
  $('#email_invites_dialog').dialog('close');
  //$('#facebook_invites_dialog').dialog('close');
  $('#invites_were_sent_dialog').dialog('open');
};

// Sign up ajax callbacks
var sign_up_error = function(e) {
  $('#sign_in_dialog .signUp .validation-error').text(e);
};
var sign_up_success = function(name) {
  location.reload(true);
};
var sign_in_success = function(name) {
  location.reload(true);
};

$(function(){
  // Init dialogs
  $('#email_invite_link').click(function(e){
    show_email_invite_dialog();
    e.preventDefault();
  });
  
  // $('#facebook_invite_link').click(function(e){
  //   show_facebook_invite_dialog();
  //   e.preventDefault();
  // });
    
  $('.invite_friend_button, .invite_friend_link, .pay_invite_button').live('click', function(e){
    show_email_invite_dialog();
  });

  $("a.invite_another").live("click", function(e){
    $('#invites_were_sent_dialog').dialog('close');
    show_email_invite_dialog();
    e.preventDefault();    
  });

  $('.nudge_friend_button').live('click', function(e){
    $('#nudge_friend_dialog #id').val($(this).data('id'));
    $('#nudge_friend_dialog .name').html($(this).data('title') + ':');
    $('#nudge_friend_dialog').dialog('open');
    $('#nudge_friend_dialog #amount').select();
    e.preventDefault();
  });

  $('#email_invite_button').click(function(e){
    validate_email_invites();
    if (!email1.hasClass('error') && !email2.hasClass('error')){
      update_sent_invites_dialog('');
      $(this).parents('form').trigger('submit.rails');
    };
    e.preventDefault();
  });

  setDefaultValue($('#name1'),  'Name');
  setDefaultValue($('#name2'),  'Name');
  setDefaultValue($('#email1'), 'Email');
  setDefaultValue($('#email2'), 'Email');

  $('#invites_were_sent_dialog').bind('dialogclose', function(event) {
    setTimeout(function(){
      pop_wingmen_panel();
    },200);
  });

  $('#invites_were_sent_close').live('click', function(e){
    $('#invites_were_sent_dialog').dialog('close');
    e.preventDefault();
  });

  $('#nudge_friend_buy_credits').click(function(e){
    $('#nudge_friend_dialog form').trigger('submit.rails');
    e.preventDefault();
  });

  // init pay dialog
  $('#buy_more_credits').click(function(e){
   $('#pay_dialog').dialog('open');
    e.preventDefault();
  });

  $('.pay_credits_button').click(function(e){
     $('#pay_dialog').dialog('close');

     ultimatePayParams["mirror"] = $(this).data("mode");
     ultimatePayParams["amount"] = $(this).data("amount");
     ultimatePayParams["amountdesc"] = $(this).data("amountdesc");
     ultimatePayParams["hash"] = $(this).data("hash");

     ulp.ultimatePay = true;
     ulp.displayUltimatePay();
     e.preventDefault();
  });  

  //init_dialog('#facebook_invites_dialog',{title:'Add your Wingmen'});
  init_dialog('#email_invites_dialog',{title:'Add your Wingmen'});
  init_dialog('#invites_were_sent_dialog',{title:'Wingmen invitation'});
  init_dialog('#nudge_friend_dialog',{title:'Nudge a friend'});
  init_dialog('#pay_dialog',{title:'Buy more credits'});
  init_dialog('#ui_dialog',{title: 'Please wait'});

  // Init popups
  $('.popup .close').live('click', function(e){
    $(this).parents('.popup').hide();
    e.preventDefault();
  });

  // init popup: sign in or sign up
  if ($('#sign_in_dialog').length) {
    init_dialog('#sign_in_dialog',{width: 500, dialogClass: 'no-title'});

    $('#sign_in_dialog .sign .close').click(function(e){
      $('#sign_in_dialog').dialog('close');
      e.preventDefault();
    });

    $('#sign_in_dialog .sign_in_tab').click(function(e){
      $('#sign_in_dialog  .sign_in_tab').addClass('active');
      $('#sign_in_dialog  .sign_up_tab').removeClass('active');
      $('#sign_in_dialog  .signIn').show();
      $('#sign_in_dialog  .signUp').hide();
      $('#sign_in_dialog  .forgotPass').hide();
      e.preventDefault();
    });

    $('#sign_in_dialog .sign_up_tab').click(function(e){
      $('#sign_in_dialog  .sign_up_tab').addClass('active');
      $('#sign_in_dialog  .sign_in_tab').removeClass('active');
      $('#sign_in_dialog  .signUp').show();
      $('#sign_in_dialog  .signIn').hide();
      $('#sign_in_dialog  .forgotPass').hide();
      e.preventDefault();
    });

    $('#forgot_link').click(function(e){
      $('#sign_in_dialog  .sign_in_tab').addClass('active');
      $('#sign_in_dialog  .sign_up_tab').removeClass('active');
      $('#sign_in_dialog  .signIn').hide();
      $('#sign_in_dialog  .signUp').hide();
      $('#sign_in_dialog  .forgotPass').show();
      e.preventDefault();
    });

    // catch error message
    $('#sign_in_form, #forgot_pass_form').bind('ajax:error', function(evt, xhr, status, error){
      var $form = $(this);
      $form.find('div.validation-error').html(xhr.responseText);
    });
  };
  // sign in or play now
  $(".playnow.active, #playnow_ladders, #play_again").live("click", function(e){
    if (typeof(signed_in) == "undefined") {
      location.href = "/users/auth/facebook"
    } else {
      $.ajax("/quiz/new");
    };
    e.preventDefault();
  });

  $(".playnow.inactive").live("click", function(e){
    alert('You cannot play now, next tournament coming soon!');
  });
  //live chat
  $('.topmenu .support_link').click(init_live_chat);
});

/* Removes leading and trailing whitespace from aString */
function trim(aString) {
	return aString
		.replace(/^\s+/, '')
		.replace(/\s+$/, '');
}
