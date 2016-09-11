function init_ladders_page(){
  // load fragment from URL hash
  if(window.location.hash.substr(0, 8) == "#ladders"){
    $('#overlay_panel .overlay_content').html('<img src="/images/loading.gif" />');
    $('#overlay_panel').show();
    $('#overlay_panel .overlay_content').load("/" + window.location.hash.substr(1))
  }

  $('.content a.row, #leader_link, .wall_user_link').live("click", function(e){
    root = $(this);
    if (root.find('.movable_content.current').length == 0) {
      path = root.data('id');
      if (!path) {
        path = root.find('.ladder-info').data('id');
      };
      $('#overlay_panel .overlay_content').html('<img src="/images/loading.gif" />');
      $('#overlay_panel').show();
      $('#overlay_panel .overlay_content').load('/ladders/' + path + '/overlay');
	  } else {
      $('#overlay_panel').hide();
	  };
    e.preventDefault();
  });

  $('#overlay_close').live('click',function(e){
    $('#overlay_panel').hide();
    e.preventDefault();
  });
  
  $('.bt_show_more').click(function(){
    var first_row = parseInt($('#ladder_rows_1 .row').first().attr("class").match(/pos_(\d+)\s/)[1]);
    var offset = (first_row - 11 < 0 ? 0 : first_row - 11);
    var limit = first_row - 1 - offset;

    if(limit > 0){
      $.get('/ladders', { offset: offset, limit: limit}, function(data){
        $('#ladder_rows_1 .row').first().before(data);
        $('#ladder_rows_1 .row').css("top", -85 * limit).animate({
          top: "+=" + (85 * limit)
        });      
      });
    };

    if (limit < 10) {
      $('.bt_show_more').hide();
    }
  });

  $('#take_tour_popup .next_step, #ladders_nudge_popup .next_step, #ladders_wingmen_popup .next_step').click(function(e){
    $(this).parents('.popup').hide();
    e.preventDefault();
  });

  $('#user_status_message, .wall_form input').live('keypress', function(e){
      $(this).addClass('enter');
      if(e.which == 13){
        $(this).parents('form').trigger("submit.rails");
        e.preventDefault();
      };
  });

  $('#user_status_message, .wall_form input').live('click', function(e){
    $this = $(this);
    if ($this.hasClass('enter') && e.pageX - $this.offset().left > parseInt($this.css("width"))) {
      $this.parents('form').trigger("submit.rails");
      $this.blur();
    };
  });

}

/*  Ladders page scroller */
var ladders_scroller = {
  init: function(params){
    var $this = this;
    this.root = $(params.root);
    this.up = $(params.up);
    this.down = $(params.down);

    if (this.rows() > 5) {
      $.extend(this.config, params);
      this.config.cache_step = this.config.step * this.config.cache_multiplier;
      this.config.displacement = this.config.step * this.row_height();
  
      if (this.config.start && this.current_position()){
        this.scroll(this.current_position() - this.start_position() - 1);
      } else {
        this.callback(0);
      };
    };
  },

  config: {
    url: '/ladders/fetch_ladders',
  },

  rows: function(){
    return this.root.children('.row').size();
  },

  row_height: function(){
    return this.root.children('.row').height();
  },

  total_height: function(){
    return this.rows() * this.row_height();
  },

  start_position: function(){
    return parseInt(this.root.children('.row:first').data('position'));
  },

  current_position: function(){
    return parseInt(this.root.find('.movable_content.current').parents('.row').data('position'));
  },

  end_position: function(){
    return parseInt(this.root.children('.row:last').data('position'));
  },

  lock: function(state){
    if (this.root) this.root.data('lock',state);
  },

  locked: function(){
    return this.root.data('lock');
  },

  toggle_button_state: function(direction, state){
    var $this = this;
    var direction;
    var button = direction ? this.up : this.down;

    if (state) {
      button.click(function(e){
        if (!$this.locked()) {
          $this.lock(true);
          $this.scroll((direction ? -1 : 1) * $this.config.step);
        };
        e.preventDefault();
      });
      button.removeClass('disabled');
    } else {
      button.unbind('click');
      button.addClass('disabled');
    };
  },
  
  have_to_load_top: function(position) {
    return position <= 0 && this.start_position() > 1;
  },
  
  have_to_load_bottom: function(position) {
    return position + this.config.displacement >= this.total_height() && this.end_position() < this.config.ladders_count;
  },
  
  callback: function(position){
    var $this = this;

    this.toggle_button_state(true,  position > 0 || this.have_to_load_top(position));
    this.toggle_button_state(false, position + this.config.displacement < this.total_height() || this.have_to_load_bottom(position));
    
    this.root.animate({scrollTop:position}, 500, function() {
      $this.lock(false);
    });
  },

  load_rows: function(offset, position, direction){
    var $this = this;
    var position, direction;
    $.ajax({
      url: this.config.url,
      data: {
        offset: offset, 
        limit: this.config.cache_step
      },
      success: function(data){
        // add rows and calculate height change
        old_height = $this.total_height();
        direction ? $this.root.prepend(data) : $this.root.append(data);
        new_height = $this.total_height();
        // if rows were added to the top scroll back to the initial point
        if (direction) {
          position = position + (new_height - old_height);  
        };
        // animate scrolling & manage locks
        $this.callback(position);
      }
    });
  },

  scroll: function(step){
    var position = this.root.scrollTop() + step * this.row_height();

    if (!this.have_to_load_top(position) && !this.have_to_load_bottom(position)) {
      // No need to load anything because we target position inside current ladder
      this.callback(position);
    } else {
      // New position is out of range so we need to load rows first
      if (position < 0){
        // Load rows to the top
        this.load_rows(this.start_position() - this.config.cache_step - 1, position, true);
      } else {
        // Load rows to the bottom
        this.load_rows(this.end_position(), position, false);
      };
    };
  }
};

// Pusher handler: update scores and move ladders
function updateLadders(params){
  var params;
  var ladder_name = '#ladder_rows_' + $('.tab.selected').attr('filter');
  if (ladder_name == '#ladder_rows_1') {
    ladder_name = '#ladders_scroller .scroller';
  };
  if (ladder_name == '#ladder_rows_2') {
    ladder_name = null;
  };
  if (ladder_name) {
    $(ladder_name).queue('floating-rows' ,function(next){
      moveLadder(ladder_name, params.row_id, params.old_position, params.new_position, params.score, next);
    });
    if (!$(ladder_name).data('lock')) {
      $(ladder_name).data('lock', true);
      $(ladder_name).dequeue('floating-rows');
    };
  };
}

// move underlying rows down, thus erasing the old and freeing new positions
function shiftRows(ladder, old_position, new_position, duration, row_height) {
  for(i=old_position-1; i>=new_position; i--){
    current_row = ladder.children('.row[data-position=' + i + ']');
    next_row = ladder.children('.row[data-position=' + (i+1) + ']');
    
    if (current_row.length > 0 && next_row.length > 0) { 
      current_content = current_row.find('.movable_content').detach();
  
      next_row.find('.movable_content').remove();
      next_row.find('.col2').append(current_content);
      current_content.find('.arrow_up').hide();
      current_content.find('.arrow_down').show();
  
      current_content.css("top",- row_height);
      current_content.animate({top: 0}, {duration: duration});
    };
  };
};

// move the row upwards
function moveLadder(ladder_name, row_id, old_position, new_position, score, next){
  // lock the scroller to avoid conflicts
  ladders_scroller.lock(true);
  
  // init variables
  var ladder = $(ladder_name);
  var row_height = ladder.find('.row').height();
  var top_position = parseInt(ladder.children('.row:first').data('position'));
  var bottom_position = parseInt(ladder.children('.row:last').data('position'));
  var load_to_top = new_position < top_position;
  var load_to_bottom = old_position > bottom_position;
  var duration;
  var next;
 

  // load missing rows
  if (load_to_top || load_to_bottom) {
    url_part =  load_to_top ? (top_position - 1) + '?mode=position' :  row_id + '?mode=id';
    $.ajax({
       url: "/ladders/" + url_part,
       async: false,
       success: function(ladder_row){
         if (load_to_top) {
           ladder.prepend(ladder_row);
           ladder.children('.row:first').attr('data-position', top_position - 1);
           ladder.scrollTop(ladder.scrollTop() + row_height);
         } else {
           ladder.append(ladder_row);
         };
       }
    });
  };
  // treat a special case: the row goes throughout the ladder
  if (load_to_top && load_to_bottom){
    duration = 2000;
    shiftRows(ladder, old_position, new_position, duration, row_height);
  } else {
    // get pointers to moving rows
    var new_row = ladder.children('.row[data-position=' + new_position + ']');
    var old_row = ladder.children('.row[data-position=' + old_position + ']');
    if (load_to_top){
      new_row = ladder.children('.row:first');
    };
    if (load_to_bottom){
      old_row = ladder.children('.row:last');
    };
    
    // calculate offset and duration
    var offset = old_row.prevAll().length - new_row.prevAll().length;
    if (load_to_bottom) {
      offset -= 1;
    };
    duration = 600 * offset;
    if (duration > 3000) { duration = 3000; };
  
    // detach old position
    var winner_content = old_row.find('.movable_content').detach();
    if (load_to_bottom){
      old_row.remove();
    };
    
    // shift loosing rows down
    shiftRows(ladder, old_position, new_position, duration, row_height);
  
    // place winning ladder to new position and hide it
    ladder.find('.row[data-position=' + new_position + '] .col2').append(winner_content);
    winner_content.find('.arrow_up').show();
    winner_content.find('.arrow_down').hide();
    winner_content.find('.score').text(addCommas(score));
    winner_content.find('.time').text('0 minutes ago');
    winner_content.hide();
  
    // add floating row to the ladder
    var fake_winner_content = winner_content.clone().show();
    if (load_to_bottom){
      ladder.find('.row:last .col2').append(fake_winner_content);
      fake_winner_content.css("top", row_height);
    } else {
      old_row.find('.col2').append(fake_winner_content);
      fake_winner_content.css("top", 0);
    };
  
    // animate winning ladder to float upwards
    fake_winner_content.animate({top: [- row_height * offset , 'easeInOutExpo']}, {
      duration: duration  * 0.8,
      complete: function(){
        fake_winner_content.hide();
        fake_winner_content.remove();
        winner_content.show();
      }
    });
  };

  // perform final actions   
  setTimeout(function(){
    // get rid of temporary row
    if (load_to_top){
        ladder.find('.row:first').remove();
        ladder.scrollTop(ladder.scrollTop() - row_height);
    };

    // unlock the scroller
    ladders_scroller.lock(false);

    // call the next animation in the queue
    next();
    
    $(ladder_name).data('lock', false);
  }, duration);
};

// Pusher handler: update wingmen panel
function updateWingmen(params){
  if ($('#user_variables').data('user_id') == params.user_id) {
    $.get('/ladders/wingmen_panel');
  };
};

// Inplace Editor for user status message
function init_edit_in_place(){
    var default_text = 'Share your thoughts here...';
    $(".inplace-editor").editInPlace({
      saving_animation_color: "#ECF2F8",
      default_text: default_text,
      text_size: 24, // size of input field
      saving_text: 'Saving ...',
      callback: function(idOfEditor, enteredText, orinalHTMLContent, settingsParams, animationCallbacks){
        enteredText = trim(enteredText).substr(0,24);
        var data = {
          user: {status_message: enteredText}
        }
        animationCallbacks.didStartSaving();
        setTimeout(animationCallbacks.didEndSaving, 2000);
        $.ajax({
          type: 'PUT',
          url: '/users/' + $(this).attr('user_id'),
          data: data
        });
        if (enteredText == '') {
          return default_text;
        } else {
          return enteredText;
        }
      }
    })
}