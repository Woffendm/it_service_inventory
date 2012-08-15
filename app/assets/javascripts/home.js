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
  var data;
  var options;
  var graphType = "column";
  var employeeResultsHidden = true;


  // Load the Visualization API and the piechart package.
  google.load('visualization', '1.0', {'packages':['corechart']});


  // Set a callback to run when the Google Visualization API is loaded.
  google.setOnLoadCallback(drawChart);


  // Callback that creates and populates a data table,
  // instantiates the pie chart, passes in the data and
  // draws it.
  function drawChart() {
    if(typeof dataToGraph != 'undefined' && dataToGraph != "none" && dataToGraph.length > 0){

      // Create the data table.
      data = new google.visualization.DataTable();
      data.addColumn('string', 'Service');
      data.addColumn('number', 'Full Time Employees');
      data.addColumn('number', 'Employee Headcount');
      data.addRows(dataToGraph);

      // Set chart options
      options = { 'title': graphTitle,
                  'width': 650,
                  'height': 300,
                  'colors' : ['#3B98A9', '#3B78A9', '#3B58A9', '#3B38A9', '#3B18A9', '#5B18A9'],
                  'legend' : 'top',
                  hAxis: {  titlePosition: 'in',
                            title: xAxisTitle,
                            titleTextStyle:{ fontSize: 14 }
                         },
                  chartArea: {  width: "80%" }
                };

      // Instantiate and draw our chart, passing in some options.
      var chart = new google.visualization.ColumnChart(document.getElementById('chart_div_1'));
      chart.draw(data, options);
      var chart = new google.visualization.PieChart(document.getElementById('chart_div_2'));
      chart.draw(data, options);
    }
  }


  //
  var toggleGraphType = $("#toggle");
  toggleGraphType.click(function(e) {
    if (graphType == "column") {
      chart = new google.visualization.PieChart(document.getElementById('chart_div_1'));
      chart.draw(data, options);
      graphType = "pie";
    }
    else {
      chart = new google.visualization.ColumnChart(document.getElementById('chart_div_1'));
      chart.draw(data, options);
      graphType = "column";
    }
  });


  //
  var toggleEmployeeResults = $("#toggle-employees");
  toggleEmployeeResults.click(function(e) {
    if(employeeResultsHidden) {
      $("#employee_results").show();
      employeeResultsHidden = false;
    } else {
      $("#employee_results").hide();
      employeeResultsHidden = true;
    }
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


  // Clears the user's selections from both of the dropdowns, returning them to the default values.
  var clearForm = $("#clear");
  clearForm.click(function(e) {
    $("#group_id option")[0].selected = true;
    $("#service_id option")[0].selected = true;
  });
});




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