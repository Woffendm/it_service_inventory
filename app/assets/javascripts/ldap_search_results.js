/**
* This file dynamically populates the search results section of the "search_ldap_view" page. 
* Whenever the user presses a key in the "last name" text box, it sends a request to the employees 
* controller to search the OSU directory for the given employee. The results of this search are then
* passed to the "ldap_search_results" page which populates its table and forms with data. Lastly,
* the "ldap_search_results" page is rendered in its designated section on the "search_ldap_view"
*/
$(document).ready(function() {
  jQuery.ajaxSetup({
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
  })
  var acceptSubmit = true;
  var firstName;
  var lastName;
  
  
  // Calls the searchLdap method if the user has entered at least two characters in the last name
  // field. There is a one second delay between requests (The name to search for is still updated
  // during this delay)
  var searchDiv = $("#search_div");
  searchDiv.keyup(function(e) {
    firstName = $('#first_name').val();
    lastName = $('#last_name').val();
    if(acceptSubmit && lastName.length > 1) {
      acceptSubmit = false;
      setTimeout(searchLdap, 1000);
    }
    return false;
  });


  // Searches the OSU directory for everyone whose last name begins with whatever is entered in the 
  // appropriate text box on the "search_ldap_view". Will further restrict search results by
  // whatever is entered in the first name field. It should be noted however that the field name of 
  // "first name" is somewhat misleading, as the first namesearch will actually return both first 
  // and middle names that match the query (this is intentional).
  function searchLdap() {
    $.ajax({
      type: "get",
      url: pathname + "?last_name=" + lastName + "&first_name=" + firstName,
      success: popLdapSearchResults
    })
    acceptSubmit = true;
  }
});


// Displays the search results in the appropriate div on the "search_ldap_view" page
function popLdapSearchResults(response) {
  $("#ldap_search_results").html(response);
  return false;
}