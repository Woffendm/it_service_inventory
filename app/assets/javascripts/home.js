/**
* This file serves controlls the javascript for the home page. Currently there are three primary 
* tasks that this file serves:
* First: When a user selects a group from the group dropdown list, the service dropdown list will be
*        automatically updated to only show services that employees of the selected group
*        have. Visa versa is also true with the service dropdown. 
* Second: If the user has submitted their selected choices, then relevant information will be
*        graphed on the page using Google's graphing api. The chosen graph types are bar and pie.
* Third: If the user wants to see detailed information about the employees belonging to a group or
*        service, then they can click a button to toggle the viewing of this information.
*/

$(document).ready(function(){
  jQuery.ajaxSetup({
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
  })



  // Set a callback to run when the Google Visualization API is loaded.
  google.setOnLoadCallback(drawChart);



  // Callback that creates and populates a data table, instantiates the pie chart, passes in 
  // the data and draws it.
  function drawChart() {
    if(typeof dataToGraph != 'undefined' && dataToGraph.length > 0){

      // Create the data table.
      data = new google.visualization.DataTable();
      data.addColumn('string', 'Service');
      data.addColumn('number', 'Full Time Employees');
      data.addColumn('number', 'Employee Headcount');
      data.addRows(dataToGraph);

      // Set bar graph options
      options_for_bar_graph = {  'height' : 475,
                                 'colors' : ['#c34500', '#000000' ],
                                 isStacked: false,
                                 legend   : { position        : 'top',
                                              alignment       : 'start' },
                                 hAxis    : { titlePosition   : 'in',
                                              title           : xAxisTitle,
                                              slantedText     : true,
                                              slantedTextAngle: 25,
                                              titleTextStyle  :{ fontSize: 14 } },
                                 chartArea: { left  : 50, 
                                              top   : 25,
                                              width : "90%"}
                               };

      // Set pie chart options
      options_for_pie_chart = { 'height'  : 475,
                                'legend'  : 'right',
                                chartArea : { left  : 50,
                                              top   : 25,
                                              width : "90%"}
                              };

      // Instantiate and draw  chart, passing in options.
      var chart1 = new google.visualization.ColumnChart(document.getElementById('bar_graph_div'));
      chart1.draw(data, options_for_bar_graph);
      var chart2 = new google.visualization.PieChart(document.getElementById('pie_chart_div'));
      chart2.draw(data, options_for_pie_chart);
    }
  }



  // Toggles visibility of 'Employee Results' page section
  var toggleEmployeeResults = $("#toggle-employees");
  toggleEmployeeResults.click(function(e) {
    $("#employee_results").toggle();
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
      type    : "GET",
      url     : servicesPathname + "?group[id]=" + groupId + "&selected_service=" + selectedService,
      success : popServiceDropdown
    })
    return true;
  });



  // Gets id of selected service, passes it to "groups" method in services controller. Default is 0   
  var serviceSelect = $("#service_dropdown");
  serviceSelect.change(function(e) {
    var selectedGroup = $("#group_id").val();
    var serviceId = "0";
    if (e.target.value) {
      serviceId = e.target.value;
    }
    $.ajax({
      type    : "GET",
      url     : groupsPathname + "?service[id]=" + serviceId + "&selected_group=" + selectedGroup,
      success : popGroupDropdown
    })
    return true;
  });



  // Clears the user's selections from both of the dropdowns, returning them to the default values.
  var clearForm = $("#clear");
  clearForm.click(function(e) {
    $.ajax({
      type    : "GET",
      url     : groupsPathname + "?service[id]=0&selected_group=nil",
      success : popGroupDropdown
    })
    $.ajax({
      type    : "GET",
      url     : servicesPathname + "?group[id]=0&selected_service=nil",
      success : popServiceDropdown
    })
    return true;
  });
});




// Replaces the group dropdown list on the home view with the updated list provided via the
// "groups" method in the services controller
function popGroupDropdown(response){
  $("#group_select_div").html(response);
  return false;
}


// Replaces the service dropdown list on the home view with the updated list provided via the
// "services" method in the groups controller
function popServiceDropdown(response){
  $("#service_select_div").html(response);
  return false;
}