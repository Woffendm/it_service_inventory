/**
* This monstrosity ensures that a user can't over-allocate an employee. It watches every allocation
*    select box on the page. When one changes, it calculates the sum of all the selected allocation
*    values on the page. If that sum exceeds 1 (indicating over-allocation), then a hidden div is
*    made visible on the page which informs the user that they must lower the allocation. In
*    addition to this, all the submit buttons on the page are hidden so that the user MUST fix the
*    over-allocation. Once fixed, the div will again be hidden and the submit buttons re-appear.
*/
$(document).ready(function(){
  var allocationSet1 = $('.allocation-1');
  var removeSet1 = $('.remove-1');
  var newAllocation1 = $(".new-allocation-1");
  var total1 = $('#total-1');
  var allocationSet2 = $('.allocation-2');
  var removeSet2 = $('.remove-2');
  var newAllocation2 = $(".new-allocation-2");
  var total2 = $('#total-2');
  
  
  
  
  // Triggers the change event for the allocation select boxes whenever a remove allocation checkbox 
  // is clicked
  removeSet1.click(function() {
    calculateAllocation(allocationSet1, 1, total1, newAllocation1, noOverAllocation1);
  });
  
  removeSet2.click(function() {
    calculateAllocation(allocationSet2, 2, total2, newAllocation2, noOverAllocation2);
  });
  
  
  
  // Triggers the change event for the allocation select boxes whenever a remove allocation checkbox 
  // is clicked
  newAllocation1.keyup(function() {
    calculateAllocation(allocationSet1, 1, total1, newAllocation1, noOverAllocation1);
  });
  
  newAllocation2.keyup(function() {
    calculateAllocation(allocationSet2, 2, total2, newAllocation2, noOverAllocation2);
  });
  
  
  
  // Watches for a change in any of the allocation select boxes
  allocationSet1.keyup(function() {
    calculateAllocation(allocationSet1, 1, total1, newAllocation1, noOverAllocation1);
  });
  
  allocationSet2.keyup(function() {
    calculateAllocation(allocationSet2, 2, total2, newAllocation2, noOverAllocation2);
  });
  
});







// Calculates total allocation for given set, populates 'total' row, hides submissions buttons if 
// over-allocation isn't allowed.
function calculateAllocation(allocationSet, removeSet, total, newAllocation, noOverAllocation) {
  var overAllocationMessage = $(".over-allocation");
  var submissionButtons = $('.submission');
  var totalAllocation = 0;
  var count = 0;
  if(null == noOverAllocation) {
    noOverAllocation = true;
  }

  
  // Gets total of all allocations on page that aren't marked for deletion
  allocationSet.each(function(e) {
    if(!$("#remove-" + removeSet + "-" + count).is(":checked")) {
      totalAllocation += parseFloat(allocationSet[count].value);
    }
    count += 1;
  });
  
  
  // Adds new allocation to total if entered
  if((newAllocation != undefined) &&
    (newAllocation.val() != "") && 
    (newAllocation.val() != undefined)) {
      totalAllocation += parseFloat(newAllocation.val());
  }
  
  
  // Populates the 'total allocation' row at the bottom of the page with the new total
  total.html(totalAllocation.toFixed(allocationPrecision) + " " + fte);
  
  
  // Hides submit buttons and shows error message if employee is over-allocated. Note that due to 
  // the inprecision of floats, the total allocation is not compared to exactly 1.
  if(noOverAllocation && (totalAllocation > 1.0001)) {
    submissionButtons.hide();
    overAllocationMessage.show();
  } 
  
  
  // Shows submit buttons and hides error message if employee allocation is acceptable
  else {
    submissionButtons.show();
    overAllocationMessage.hide();
  }
}