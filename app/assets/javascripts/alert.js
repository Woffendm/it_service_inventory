/*
*  This makes automatically fading alerts using pixy dust and magic
*/
$(document).ready(function(){  
  $(".alert-success, .alert-error, .alert-info").alert();
  
  
  $(".alert-success").fadeOut(4000);
  
  
  $(".alert-success").mouseenter(function(){
    $(this).stop().fadeOut(0).fadeIn(0);
  });
  
  
  $(".alert-success").mouseleave(function(){
    $(this).fadeOut(2500);
  });
});