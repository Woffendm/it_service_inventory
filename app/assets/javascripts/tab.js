/**
*  This creates a delicious cookie which remembers which tab the user was on. If there is a tab id 
*     saved on the cookie, then it opens that tab. This is used for when the user uses pagination. 
*  The second chunk of code sets up warnings for tabbed navigation that goes to different views that  *     warn the user to save their changes before switching pages.
*/
$(document).ready(function(){
  $("#my-tab a").click(function(){
    $.cookie("current_tab", this.id, { path: '/'});
  });
  
  if($.cookie('current_tab') != null) {
    $("#" + $.cookie('current_tab')).tab('show');
  }

});