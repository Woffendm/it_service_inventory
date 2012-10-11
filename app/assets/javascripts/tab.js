/**
*  This creates a delicious cookie which remembers which tab the user was on. If there is a tab id 
*     saved on the cookie, then it opens that tab. This is used for when the user uses pagination. 
*/
$(document).ready(function(){
  $(".nav-tabs > li > a").click(function(){
    $.cookie("current_tab", this.id);
  });
  
  if($.cookie('current_tab') != null) {
    $("#" + $.cookie('current_tab')).tab('show');
  }
});