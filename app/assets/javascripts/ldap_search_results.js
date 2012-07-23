/**
* This file dynamically populates the search results section of the "search_ldap_view" page. 
* Whenever the user presses a key in the "last name" text box, it sends a request to the employees 
* controller to search the OSU directory for the given employee. The results of this search are then
* passed to the "ldap_search_results" page which populates its table and forms with data. Lastly,
* the "ldap_search_results" page is rendered in its designated section on the "search_ldap_view"
*/
$(document).ready(function(){
	jQuery.ajaxSetup({
		'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
	})
	
	
	// Searches the OSU directory for everyone whose last name begins with whatever is entered in the 
	// appropriate text box on the "search_ldap_view". Appends first name to query if that is entered.
	// Because of the way the search works, the last name must be COMPLETELY entered before a first
	// name is entered. 
	var searchDiv = $("#search_div");
	searchDiv.keyup(function(e) {
		var searchVal = $('#first_name').val();
		var searchVal2 = $('#last_name').val();
		if(searchVal2.length > 1){
			$.ajax({
				type: "get",
				url: "/employees/ldap_search_results?last_name=" + searchVal2 + "&first_name=" + searchVal,
				success: popLdapSearchResults
			})
		}
		return false;
	});
});


// Displays the search results in the appropriate div on the "search_ldap_view" page
function popLdapSearchResults(response){
	lastNameSearch = $("#last_name")
	$("#ldap_search_results").html(response);
	return false;
}