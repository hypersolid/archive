$(document).ready(function() {
  var stations = [];

  $('.button').click(function() {
    $.ajax({
      url : window.location,
      data : {
        stations : stations,
        line : $(this).data('id')
      }
    });
    stations = [];
    $('#text').val('');
  });

  $('.destroy').click(function() {
    $.ajax({
      url : window.location,
      data : {
        stations : stations,
        destroy : true
      }
    });
    stations = [];
    $('#text').val('');
  });
  
  $('.drop').click(function() {
    $.ajax({
      url : window.location,
      data : {
        stations : stations,
        drop : true
      }
    });
    stations = [];
    $('#text').val('');
  });
  
  $('.rename').click(function() {
    $.ajax({
      url : window.location,
      data : {
        stations : stations,
        rename : $('#name').val()
      }
    });
    stations = [];
    $('#text').val('');
  });

  $('.rotate').click(function() {
    $.ajax({
      url : window.location,
      data : {
        stations : stations,
        rotate : $(this).html()
      }
    });
    stations = [];
    $('#text').val('');
  });

  // weave routine
  $('circle,rect').click(function() {
    id = $(this).data('id');
    stations.push(id);
    $('#text').val($('#text').val() + ' ' + id);
  });

  $(document).keyup(function(e){
    if(e.keyCode === 27) {
      stations = [];
      $('#text').val('');  
    };
  });

  load_and_center_the_map();
});

