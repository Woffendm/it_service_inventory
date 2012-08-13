/**
* This file serves two primary purposes on the home view.
* First: dynamically populate the dropdown list of employees based on the selection made in the 
*         group dropdown
* Second: dynamically populate the search-results section of the page based on the selection made
*         in the employees dropdown
*/

$(document).ready(function(){
  jQuery.ajaxSetup({
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
  })


  //
  var search = $("#search");
  search.click(function(e) {
    var serviceId = 1;
    var groupId = 1;
    //var serviceId = $("#service_id").val();
    //var groupId = $("#group_id").val();
    $.ajax({
      type: "GET",
      url: totalAllocationWithinGroupPathname + "?group=" + groupId + "&service=" + serviceId,
      success: drawGraph
    })
    return true;
  });


  // Gets id of selected group, passes it to "services" method in groups controller. Default is 0.
  var groupSelect = $("#group_dropdown");
  groupSelect.change(function(e) {
    var selectedService = $("#service_id").val();
    var groupId = "0";
    if (e.target.value) {
      groupId =  e.target.value;
    }
    $.ajax({
      type: "GET",
      url: servicesPathname + "?group[id]=" + groupId + "&selected_service=" + selectedService,
      success: popServiceDropdown
    })
    return true;
  });
  
  
  // Gets id of selected employee, passes it to "populate_employee_results" method in employees   
  // controller 
  var serviceSelect = $("#service_dropdown");
  serviceSelect.change(function(e) {
    var selectedGroup = $("#group_id").val();
    var serviceId = "0";
    if (e.target.value) {
       serviceId = e.target.value;
    }
    $.ajax({
      type: "GET",
      url: groupsPathname + "?service[id]=" + serviceId + "&selected_group=" + selectedGroup,
      success: popGroupDropdown
    })
    return true;
  });
});




//
function drawGraph(response){
  
  // Load the Visualization API and the piechart package.
  google.load('visualization', '1.0', {'packages':['corechart']});
  
  // Set a callback to run when the Google Visualization API is loaded.
  google.setOnLoadCallback(drawChart);
  
  
  // Callback that creates and populates a data table,
  // instantiates the pie chart, passes in the data and
  // draws it.
  function drawChart() {

    // Create the data table.
    var data = new google.visualization.DataTable();
    data.addColumn('string', 'Service');
    data.addColumn('number', 'Allocation');
    data.addRows(response);

    // Set chart options
    var options = {'title':'Total Allocations for Group',
                   'width':400,
                   'height':300};

    // Instantiate and draw our chart, passing in some options.
    var chart = new google.visualization.BarChart(document.getElementById('chart_div'));
    chart.draw(data, options);
  }
  return false;
}




// Replaces the employee dropdown list on the home view with the updated list provided via the
// "employees" method in the groups controller
function popGroupDropdown(response){
  $("#group_select_div").html(response);
  return false;
}


// Populates the employee results div on the home view with relevant information provided via the 
// "populate_employee_results" method in employees controller
function popServiceDropdown(response){
  $("#service_select_div").html(response);
  return false;
}