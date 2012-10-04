/**
* 
*/
$(document).ready(function(){
  $(".nav-tabs > li > a").click(function(){
    $.cookie("current_tab", this.id);
  });
  
  if($.cookie('current_tab') != null) {
    $("#" + $.cookie('current_tab')).tab('show');
  }
});