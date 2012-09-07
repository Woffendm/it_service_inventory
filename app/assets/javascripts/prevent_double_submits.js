$(document).ready(function(){

var beenSubmitted = false;

  $(".prevent_double_submit").submit(function() {
    if (beenSubmitted) { return false; }
    beenSubmitted = true;
  });

});