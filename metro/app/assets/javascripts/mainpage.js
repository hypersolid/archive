$(document).ready(function(){
  //map
  $('#worldmap').vectorMap({
    map : 'world_mill_en',
    markerStyle : {
      initial : {
        fill : 'yellow',
        stroke : '#333'
      }
    },
    backgroundColor : 'transparent',
    markers : the_cities_public,
    onMarkerClick : function(e, code) {
      window.location = '/' + the_cities[code]['name'].split(',')[0].toLowerCase();
    }
  });

  //autocomplete
  $("#ac").autocomplete({
    source : availableTags,
    autoFocus : true,
    select : function(event, ui) {
      window.location = '/' + ui.item['label'].split(',')[0].toLowerCase();
    }
  });
  $("#ac").focus(function() {
    $(this).val('');
  });
});
