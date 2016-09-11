$(function(){
  // init popup: welcome
  if ($('#welcome_dialog').length > 0) {
    init_dialog('#welcome_dialog',{title:'Welcome'});
    $('#welcome_dialog .start_playing_button').click(function(){
      $('#welcome_dialog').dialog('close');
    });
    $('#welcome_dialog').dialog('option', { width: 500, height: 315}).dialog('open');
  };
});
// ------------------------------------------------------
// Get Ready Page animation
// ------------------------------------------------------
var quiz_page = {
  init: function(config) {
    this.config = config;
    $.preLoadImages('/images/quiz/bg_stats_prize.png',
        '/images/quiz/bg_stats_friend.png',
        '/images/quiz/bg_stats_table.png',
        '/images/quiz/bn_play_again.png',
        '/images/quiz/bg_wingmen_panel.png',
        '/images/quiz/bg_stats.png',
        '/images/shared/blob_medium.png',
        '/images/shared/blob_pending.png',
        '/images/shared/bn_playnow_medium.png',
        '/images/shared/bn_gray.png',
        '/images/shared/anybody.jpg'
    );
    if (this.config.popups){
      $.preLoadImages(
        '/images/quiz/bonus1_picture.png',
        '/images/quiz/bonus2_picture.png',
        '/images/shared/popup_pointer_right.png',
        '/images/shared/popup_pointer_left.png',
        '/images/shared/popup_close.png',
        '/images/shared/bt_popup_next_step.png'
      );
      this.howToPlay();
    };
  },
  
  ready: function() {
    $('#quiz_question #get_ready_trigger').remove();
    $('#answer1, #answer2, #answer3').show();
    $('#quiz_question .question_number').show();
  },

  reset: function() {
    this.spawnHourglass();
    this.removeBonuses();

    for (i=1;i<=3;i++) {
      $('#answer' + i).children('.wrapper').text(this.config.answers[i - 1]);
      $('#answer_container' + i).attr('href', this.config.answers[i - 1]);
    };

    for (var key in this.config.view) {
      $(key).html(this.config.view[key]);  
    };

    $('.answers a').css('color','white'); //FF bug
    $('#quiz_stats .prize').toggle(this.config.view_next_prize);
    $('#quiz_stats .friend').toggle(this.config.view_next_friend);
    $('#quiz_question').addClass('active');
    $('#seconds_left').html(this.config.total_time);

    if (parseInt($('#round_score').html()) > 0) {
      $('#quiz_stats').show();
    };

    this.config.start_time = null;
    this.config.round_bonus = this.config.bonus;
  },
  
  start: function(config) {
    var $this = this;
    $.extend(this.config, config);

    this.reset();
    this.spawnIndicator();

    setTimeout(function(){
      $this.spawnBonus(1);
      if (!$this.config.merge_bonuses) {
        $this.spawnBonus(2);
      };
    }, 800);
    setTimeout('quiz_page.removeHourglass()',1500);
    setTimeout(function(){
      $this.countDownTime();
      $this.countDownEvents();
      if ($this.config.passes_left > 0) {
        $this.initPassButton();
      };
      $this.initAnswers();
      $this.animateIndicator();
    },2000);
  },
  
  // Actions
  checkAnswer: function(event, element) {
    var $this = this;

    this.blockInterface();
    this.config.points_left = this.pointsLeft();
    $('#bubble .platform').text(this.config.points_left);
    
    $.ajax({
      url: $this.config.answer_url,
      data: {
              answer: $(element).attr("href"),
              score : $this.config.points_left},
      success: function(response) {
        $this.doWinAction(element);
      },
      error: function(response) {
        $this.doLooseAction(element, response.responseText);
      }
    });
  },
      
  doWinAction: function(element, answer) {
    var $this = this;

    $('#quiz_question').removeClass('active');

    // highlight the correct answer
    id = $(element).children('.answer').attr('id');
    setTimeout("$('#"+id+"').addClass('correct')", 0);
    setTimeout("$('#"+id+"').removeClass('correct')",300);
    setTimeout("$('#"+id+"').addClass('correct')",600);
    setTimeout("$('#"+id+"').removeClass('correct')",900);
    setTimeout("$('#"+id+"').addClass('correct')",1200);
    setTimeout("$('#"+id+"').removeClass('correct')",2500);

    // update scores
    if (parseInt($('#round_score').html()) > 0) {
      this.flyingScores();
    } else {
      this.spinningScores();
    };

    eval(answer);
    if (this.config.popups && parseInt($('#round_score').html()) == 0 && this.config.points_left > 0) {
      setTimeout(function() {
        $('#quiz_scorer_popup').css('top', parseInt($('#bonus1').css('top')) - 27);
        $('#quiz_scorer_popup').show();
        $('#quiz_scorer_popup').animate({
            left:$('#quiz_scorer_popup').width() + 115
          },{
            easing: 'easeOutBounce',
            duration:500,
        });
      }, 2000);
    } else {
      setTimeout(function() {$this.start(params)},4500);
    };
  },

  doLooseAction: function(element, results) {
    var $this = this;
    $('#quiz_question').removeClass('active');
    $('#quiz_question').addClass('wrong')
    $(element).children('.answer').addClass('wrong');
    
    setTimeout(function(){
    	window.location = $this.config.game_over_url;
    },1000);
  },

  doTimeOutAction: function(element) {
    this.blockInterface(true);
    $('#bubble .platform').text(0);
    $('#seconds_left').text(0);

    this.doLooseAction();
  },
  
  // Bubbles
  spawnBonus: function(number){
   time = (number == 1 ? this.config.best_time : this.config.avg_time);
   position = this.config.scorer_height * (time / this.config.total_time) - 3;
   $('#bonus' + number + ' .platform').show();
   $('#bonus' + number).show();
   $('#bonus' + number).animate({
            top: position,
          },
          {
            duration:  400,
            easing: "linear",
          });
  },

  setIndicator: function(percent){
    $('#scorer_top').css('height',this.config.scorer_height * (1 - percent / 100));
    $('#scorer_indicator').show();
  },

  spawnIndicator: function(){
    var $this = this;
    $('#bubble .platform').show();
    $('#bubble .platform').text(this.config.points_total);
    $('#scorer_top').animate({
            height: 0
          },
          {
            duration:  1000,
            step: function(now){
              points = ($this.config.scorer_height - now) / $this.config.scorer_height * $this.config.points_total;
              $('#bubble .platform').text(Math.round(points));
            },
            easing: "linear",
          });
  },

  // Locks 
  blockInterface: function(completely) {
    clearTimeout(this.config.looseTimeoutId);
    clearTimeout(this.config.bestTimeoutId);
    clearTimeout(this.config.avgTimeoutId);
    clearInterval(this.config.timeIntervalId);
    $('#scorer_top').stop();

    this.blockAnswers();
    this.blockPassButton();
    
    if (completely) {
      $('#quiz_question').removeClass('active');  
    };
  },

  blockAnswers: function(){
    $('.answers a').unbind('click');
    $('.answers a').click(function(e){e.preventDefault()});
  },

  blockPassButton: function(){
    $('#pass_button').removeClass('active');
    $('#pass_button').unbind('click');
    $('#pass_button').click(function(e){e.preventDefault()});
  },

  removeBonuses: function(){
   $('#bonus1, #bonus2').hide();
   $('#bonus1, #bonus2').css('top',this.config.scorer_height);
   $('#bonus1 .merge').toggle(this.config.merge_bonuses);
   $('#bonus1 .split').toggle(!this.config.merge_bonuses);
  },

  // Binders, Initializers, Unlockers
  initPassButton: function(){
    var $this = this;
    $('#pass_button').addClass('active');
    $('#pass_button').click(function(e) {
      $this.blockInterface(true);
      $.ajax({
        url: $this.config.answer_url,
        data: {
                score : $this.pointsLeft()},
        success: function(answer){
          eval(answer);
          setTimeout(function() {$this.start(params)},2000);
        }
      });
      e.preventDefault();
    });
  },

  initAnswers: function(){
    var $this = this;
    $('.answers a').click(function(e) {
      $this.checkAnswer(e, $(this));
      e.preventDefault();
    });
  },

  spawnHourglass: function(){
    $('#hourglass').css('height', this.config.hourglass_height);
    $('#hourglass').show();
    $('#quiz_question .question .text').hide();
  },
  
  removeHourglass: function(){
    $('#quiz_question .question .text').show();
    target_height = $('#quiz_question .question').height() + $('#quiz_question .answers').height();
    $('#hourglass').css('height', target_height - 60);
    $('#hourglass').fadeOut(300);
  },

  //Utility functions
  timeToPoints: function(time){
    return time / this.config.total_time * this.config.points_total;
  },
  pointsToTime: function(points){
    return points / this.config.points_total * this.config.total_time * 1000;
  },
  pointsLeft: function(){
    points = 0;
    if (this.config.start_time) {
      time_delta = (new Date() - this.config.start_time) / 1000;
      time_fraction_left = 1 - time_delta / this.config.total_time;
      points = Math.round(time_fraction_left * this.config.points_total);
    };
    return (points >= 0 ? points : points);
  },
  
  // Countdowns
  countDownEvents: function() {
    var $this = this;

    this.config.looseTimeoutId = setTimeout(function(){
      $this.doTimeOutAction();
    }, this.config.total_time * 1000);

    this.config.bestTimeoutId = setTimeout(function(){
      $('#bonus1').fadeOut();
      $this.config.round_bonus -= $this.config.best_time_bonus;
    }, this.config.best_time * 1000);

    this.config.avgTimeoutId = setTimeout(function(){
      $('#bonus2').fadeOut();
      $this.config.round_bonus -= $this.config.avg_time_bonus;
    }, this.config.avg_time * 1000);
  },

  countDownTime: function() {
    var $this = this;
    this.config.start_time = new Date();
    this.config.timeIntervalId = setInterval(function(){
      element = $('#seconds_left');
      time_left = parseInt(element.html());
      if (time_left == 1) {
        clearInterval($this.config.timeIntervalId);
      };
      element.html(time_left - 1);
    },1000);
  },
  
  animateIndicator: function(){
    var $this = this;
    $('#scorer_top').css('height', 0);
    $('#scorer_top').animate({
      height: this.config.scorer_height,
    }, {
      duration: this.config.total_time * 1000,
      easing: "linear",
      step: function() {
        $('#bubble .platform').text($this.pointsLeft());
      }
    });
  },

  // How to play popups
  howToPlay: function(){
    var $this = this;
    $('#quiz_scorer_popup .close, #quiz_stats_popup .close, #quiz_pass_popup .close').click(function(e){
      $this.start();
      e.preventDefault();
    });
    $('#quiz_scorer_popup .next_step').click(function(e){
      $('#quiz_scorer_popup').hide();
      $('#quiz_stats_popup').show();
      $('#quiz_stats').show();
      $('#quiz_stats_popup').animate({
          left:$('#quiz_stats').width()
        },{
          easing: 'easeOutBounce',
          duration:500,
      });
      e.preventDefault();
    });
    $('#quiz_stats_popup .next_step').click(function(e){
      $('#quiz_stats_popup').hide();
      $('#quiz_pass_popup').show();
      $('#quiz_pass_popup').animate({
          left:255
        },{
          easing: 'easeOutBounce',
          duration:500,
      });
      $.extend($this.config, params);
      $this.reset();
      e.preventDefault();
    });
    $('#quiz_pass_popup .next_step').click(function(e){
      $('#quiz_pass_popup').hide();
      $this.start(params);
      e.preventDefault();
    });
  },

  // Misc
  flyingScores: function(){
    fly = function(selector, left, top, flight_time){
      var selector;
      $(selector).animate({left: - left, top: - top},
        {
          duration: flight_time,
          complete: function(){
            $(selector).hide();
            $(selector).css({left: 0, top: 0});
          }
      });
    };
    p = {
      bonus_offset_left:755,
      bubble_offset_left:632,
      bonus_offset_top:45,
      bubble_offset_top:49,
      flight_time:1000
    };
    fly('#bonus1 .platform', p.bonus_offset_left, parseInt($('#bonus1').css('top')) - p.bonus_offset_top, p.flight_time);
    fly('#bonus2 .platform', p.bonus_offset_left, parseInt($('#bonus2').css('top')) - p.bonus_offset_top, p.flight_time);
    fly('#bubble .platform', p.bubble_offset_left, $('#scorer_top').height() - p.bubble_offset_top, p.flight_time);

    var $this = this;
    setTimeout(function() {$this.spinningScores()}, p.flight_time);
  },

  spinningScores: function(){
    duration = 1000;
    steps = 20;
    current_score = parseInt($('#round_score').html());
    current_total_score = parseInt($('#total_score').html());
    points = this.config.points_left + this.config.round_bonus;
    for (i = 0; i < steps; i++){
      cmd = "$('#round_score').html(" + Math.round(current_score + points / (steps - i)) + ");";
      cmd += "$('#total_score').html(" + Math.round(current_total_score + points / (steps - i)) + ");";
      setTimeout(cmd, duration * (i + 1) / steps);
    };
  },
}