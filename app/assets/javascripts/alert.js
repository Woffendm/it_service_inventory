/*
*  This makes automatically fading alerts using pixy dust and magic
*/
$(document).ready(function(){
  $("#flash").fadeOut(7000);
  
  
  
  $("#flash").hover(
    function() {
      $(this).stop().fadeOut(0).fadeIn(0);
    },
    function() {
      $(this).fadeOut(2500);
    }
  );
});