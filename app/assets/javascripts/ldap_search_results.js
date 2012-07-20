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
	// appropriate text box on the "search_ldap_view" page
	var lastNameSearch = $("#last_name_search");
	lastNameSearch.keyup(function(e) {
		var searchVal = e.target.value;
		$.ajax({
			type: "post",
			url: "/employees/ldap_search_results?last_name=" + searchVal,
			success: popLdapSearchResults
		})
		return true;
	});
});


// Displays the search results in the appropriate div on the "search_ldap_view" page
function popLdapSearchResults(response){
	lastNameSearch = $("#last_name")
	$("#ldap_search_results").html(response);
	return false;
}