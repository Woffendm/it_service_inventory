/**
* This monstrosity ensures that a user can't over-allocate an employee. It watches every allocation
*    select box on the page. When one changes, it calculates the sum of all the selected allocation
*    values on the page. If that sum exceeds 1 (indicating over-allocation), then a hidden div is
*    made visible on the page which informs the user that they must lower the allocation. In
*    addition to this, all the submit buttons on the page are hidden so that the user MUST fix the
*    over-allocation. Once fixed, the div will again be hidden and the submit buttons re-appear.
*/
$(document).ready(function(){
  var overAllocationMessage = $("#over_allocation");
  var submissionButtons = $('input.submission');
  var allocationValues = $('.allocation_value');
  var removeAllocations = $('.remove_allocation');
  var newAllocationValue = $("#employee_allocations_allocation")
  
  
  // Triggers the change event for the allocation select boxes whenever a remove allocation checkbox 
  // is clicked
  removeAllocations.click(function(e) {
    allocationValues.trigger("change");
  });
  
  
  
  // Watches for a change in any of the allocation select boxes
  allocationValues.change(function(e) {
    var totalAllocation = 0;
    var count = 1;
    
    
    // Gets total of all allocations on page that aren't marked for deletion
    while(count < allocationValues.length) {
      if(!$("#employee_employee_allocations_attributes_" + (count - 1) +
            "__destroy").is(":checked")) {
        totalAllocation += parseFloat(allocationValues[count].value);
      }
      count += 1;
    }
    if((newAllocationValue.val() != "") && (newAllocationValue.val() != undefined)) {
      totalAllocation += parseFloat(newAllocationValue.val());
    }
    
    
    // Hides submit buttons and shows error message if employee is over-allocated
    if( totalAllocation > 1 ) {
      count = 0;
      while(count < submissionButtons.length) {
        submissionButtons[count].hidden = true;
        overAllocationMessage.show();
        count += 1;
      }
    } 
    
    
    // Shows submit buttons and hides error message if employee allocation is acceptable
    else {
      count = 0;
      while(count < submissionButtons.length) {
        submissionButtons[count].hidden = false;
        overAllocationMessage.hide();
        count += 1;
      }
    }
  });
});