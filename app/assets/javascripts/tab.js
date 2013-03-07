/**
*  This creates a delicious cookie which remembers which tab the user was on. If there is a tab id 
*     saved on the cookie, then it opens that tab. Cookie is valid across the entire site
*/
$(document).ready(function(){
  $("#my-tab a").click(function(){
    $.cookie("awesome_tab", this.id, { path: '/', expires: 2 });
  });
  
  if($.cookie("awesome_tab") != null) {
    $("#" + $.cookie('awesome_tab')).tab('show');
  }

});