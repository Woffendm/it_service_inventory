/**
* This file serves two primary purposes on the home view.
* First: dynamically populate the dropdown list of employees based on the selection made in the 
*         group dropdown
*  Second: dynamically populate the search-results section of the page based on the selection made
*         in the employees dropdown
*/

$(document).ready(function(){
  jQuery.ajaxSetup({
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
  })


  // Gets id of selected group, passes it to "employees" method in groups controller. Default is 0.
  var groupSelect = $("#group_dropdown");
  groupSelect.change(function(e) {
    var groupId = "0";
    if (e.target.value) {
      groupId =  e.target.value;
    }
    $.ajax({
      type: "GET",
      url: employeesPathname + "?group[id]=" + groupId,
      success: popEmployeeDropdown
    })
    return true;
  });
  
  
  // Gets id of selected employee, passes it to "populate_employee_results" method in employees   
  // controller 
  var employeeSelect = $("#employee_dropdown");
  employeeSelect.change(function(e) {
    var employeeId = "0";
    if (e.target.value) {
       employeeId = e.target.value;
    }
    $.ajax({
      type: "GET",
      url: populateEmployeeResultsPathname + "?employee[id]=" + employeeId,
      success: popEmployeeResults
    })
    return true;
  });
});


// Replaces the employee dropdown list on the home view with the updated list provided via the
// "employees" method in the groups controller
function popEmployeeDropdown(response){
  $("#employee_select_div").html(response);
  $("#employee_results").html(" ");
  return false;
}


// Populates the employee results div on the home view with relevant information provided via the 
// "populate_employee_results" method in employees controller
function popEmployeeResults(response){
  $("#employee_results").html(response);
  return false;
}