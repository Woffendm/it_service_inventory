/**
* This file sets up the Full Time Employee calculator dialogue window on the Edit Employee page.
* The Full Time Employee calculator is used to calculate the user's allocation to a given service, 
* because most people don't know their allocations off the top of their heads.
*/
$(document).ready(function(){
  
  // Sets the specified content to be a dialog window, and also sets some options for it. 
  $("#fte_calculator").dialog({ 
    autoOpen  : false,
    width     : "auto",
    modal     : true,
    closeText : "",
    show      : "drop",
    title     : "Allocation Calculator",
    close     : function(event){
      correspondingSelectBox = null;
    } 
  });



  // Establishes a number of variables to be used later on. Variables in all caps are constants.
  var correspondingSelectBox;
  var fteResult;
  var hoursPerDay = $('#hours_per_day');
  var hoursPerWeek = $('#hours_per_week');
  var useThisNumber = $('#use_this_number');
  var TABKEY = 9;



  // Closes and clears any open FTE calculator dialogue windows. Opens the FTE calculator next to
  // the trigger when user clicks on the trigger. Sets the corresponding select box to whichever
  // select box came directly before the trigger. 
  $(".fte_calculator_trigger").click(function(e){ 
    if(correspondingSelectBox != $(".calculator_select")[$(".fte_calculator_trigger").index(this)]){
      $("#fte_calculator").dialog("close");
      correspondingSelectBox = $(".calculator_select")[$(".fte_calculator_trigger").index(this)];
      hoursPerDay.val("");
      hoursPerWeek.val("");
      popAllocationResult(0)
      $("#fte_calculator").dialog("open");
    }
  });



  // Watches for a keypress in the hours-per-day box. If one is detected and it is not a tab, then
  // it calculates the FTE value of the entry, clears the other box, and calls popAllocationResult 
  hoursPerDay.keyup(function(e) {
    if (e.keyCode != TABKEY) {
      fteResult = (e.target.value / (fteHoursPerWeek / 5));
      hoursPerWeek.val("");
      popAllocationResult(fteResult);
    }
  });



  // Watches for a keypress in the hours-per-Week box. If one is detected and it is not a tab, then
  // it calculates the FTE value of the entry, clears the other box, and calls popAllocationResult
  hoursPerWeek.keyup(function(e) {
    if (e.keyCode != TABKEY) {
      hoursPerDay.val("");
      fteResult = (e.target.value / fteHoursPerWeek);
      popAllocationResult(fteResult);
    }
  });


  // Sets the selected value in the corresponding select box to the calculated value. Fires the 
  // 'change' event for the select box.
  useThisNumber.click(function(e) {
    fteResult = Math.round(fteResult*Math.pow(10,allocationPrecision)) /
                Math.pow(10,allocationPrecision);
    if(fteResult == 1) {
      fteResult = "1.0";
    }
    correspondingSelectBox.value = fteResult;
    $(".calculator_select").trigger("change");
    $("#fte_calculator").dialog("close");
  });
});



// If the calculated result is positive and below 1, then it is displayed in its apropriate div and 
// can be clicked upon to automatically set the corresponding select box to the calculated value. If 
// the value is zero, it cannot be clicked upon because there is no 0 value in the select box. If 
// the user entered a negative number or non-number character, then it displays an apropriate 
// message. If the calculated value is greater than 1, displays an apropriate message.
function popAllocationResult(fteResult){
  $("#use_this_number").html("");
  if(fteResult > 1) {
    $("#allocation_result_container").html("You are over allocated!");
  } 
  else if(isNaN(fteResult) || (fteResult < 0)) {
    $("#allocation_result_container").html("Time incorrectly entered!");
  } 
  else {
    $("#allocation_result_container").html("");
    if(fteResult > 0) {
      $("#use_this_number").html("Your allocation is <a>" + 
                                 fteResult.toFixed(allocationPrecision) + " FTE </a>");
    }
    else {
      $("#use_this_number").html("Your allocation is 0 FTE");
    }
  }
  return false;
}