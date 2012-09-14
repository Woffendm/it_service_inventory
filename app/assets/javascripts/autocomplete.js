/**
* This file sets up tooltips throughout the application. Tooltips are text boxes that show up when
*    you hover over text, and provide additional information. 
*/
$(document).ready(function(){
  var testArray = [{label: "bob", id: "1"}, {label: "frank", id: "2"}];
  // 
  $("#test").autocomplete({
    source: testArray
  });
});