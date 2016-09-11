$(function(){
  var dropbox={};
  
  
  function render_dropbox(){
    $list = $('#list');
    $total = $('#total');
    
    $list.html('');
    
    sum = 0;
    result = [];
    for (v in dropbox){
      vv = dropbox[v];
      line = '<div class="name">'+vv['name']+'</div>';
      line += '<div class="amount">';
      if (vv['count']>1) {
        line += vv['count']+' по ';
      };
      line += vv['price']+'&nbsp;<del>P</del>';
      line += '</div>';
      line += '&nbsp;<span data-id="'+ v +'" class="minus">Не&nbsp;надо</span>';
      line += '&nbsp;<span data-id="'+ v +'" class="plus">Ещё</span>';
      line += '<div class="bordersmall"></div>';
      result.push(line);
      sum +=  vv['price'] * vv['count'];
    };
    $list.html(result.join(''));
    $total.html(sum);
  };
  
  $('#card .item').live("click",function(){
    $this = $(this); 
    add = parseInt($this.data('price'));
    
    $.get('/woofer/'+$this.data('id'));
    
    if ($this.data('id') in dropbox){
      dropbox[$this.data('id')]['count']+=1;
    } else {
      dropbox[$this.data('id')] = {name:$this.data('name'),price:parseInt($this.data('price')),count:1};
    };
    
    if (parseInt($('#order').css('bottom'))==0) {
      render_dropbox();  
    };
    
    $('#makeorder').show();
  });
  
  $('#makeorder').click(function(){
    $.ajax({
            
      type: "POST",
      url: '/orders/make',
      data: {
              page:$('h1').html(),
              list:dropbox,
              total:$('#total').html()
            }
    });
      
    $(this).remove();
    $('#phonescontainer').show();
  });
  
  $('#ordertrigger').click(function(){
    obj = $('#order');
    offset = parseInt(obj.css('bottom'));
    if (offset==0){
        obj.css('bottom',- obj.height() + 50);
        $('#ordertrigger').html('показать&uarr;');
    } else {
        render_dropbox();
        obj.css('bottom',0);
        $('#ordertrigger').html('убрать&darr;');
    };
  });
  
  $('.plus').live('click', function(){
    $('.item[data-id="'+$(this).data('id')+'"]').click();  
  });
  
  $('.minus').live('click', function(){
    el = dropbox[$(this).data('id')];
    if (el['count']>1) {
      el['count']-=1;
    } else {
      delete dropbox[$(this).data('id')];      
    };
    render_dropbox();
  });
  
  $('#comments_trigger').click(function(){
    $('#comments').toggle();
    if ($('#comments').is(":visible")) {
      $(this).html('Убрать отзывы');        
    } else {
      $(this).html('Показать отзывы');
    };
  });
  
});
