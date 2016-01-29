function scrollToBottom(id){
  div_height = $("#"+id).height();
  div_offset = $("#"+id).offset().top;
  window_height = $(window).height();
  $('html,body').animate({
    scrollTop: div_offset-window_height+div_height
  },'slow');
}