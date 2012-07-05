$(document).ready(function(){
	jQuery.ajaxSetup({
		'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
	})


	var groupSelect = $("#group_dropdown");
	groupSelect.change(function(e) {
		var groupId = e.target.value;
		$.ajax({
			type: "GET",
			url: "/groups/employees?group[id]=" + groupId,
			success: popEmployeeDropdown
		})
		return true;
	});
	
	
	var employeeSelect = $("#employee_dropdown");
	employeeSelect.click(function(e) {
		var employeeId = e.target.value;
		$.ajax({
			type: "GET",
			url: "/employees/populate_employee_results?employee[id]=" + employeeId,
			success: popEmployeeResults
		})
		return true;
	});
});



function popEmployeeDropdown(response){
	groupSelect = $("#group")
	$("#employee_select_div").html(response);
	return false;
}


function popEmployeeResults(response){
	employeeSelect = $("#employee")
	$("#employee_results").html(response);
	return false;
}