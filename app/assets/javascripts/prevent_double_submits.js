// This file prevents forms from being submitted multiple times.
$(document).ready(function(){
  var beenSubmitted = false;
  
  
  //Only allows form to be submitted once.
  $("form").submit(function() {
    if (beenSubmitted) { return false; }
    beenSubmitted = true;
  });
});