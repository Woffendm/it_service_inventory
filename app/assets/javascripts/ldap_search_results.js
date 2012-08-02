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
  // appropriate text box on the "search_ldap_view" provided that the entry has at least two 
  // characters. After the user enters at least two characters for the last name field, the method 
  // will further restrict search results by whatever is entered in the first name field. It should 
  // be noted however that the field name of "first name" is somewhat misleading, as the first name 
  // search will actually return both first and middle names that match the query (this is 
  // intentional).
  var searchDiv = $("#search_div");
  searchDiv.keyup(function(e) {
    var first_name = $('#first_name').val();
    var last_name = $('#last_name').val();
    if (last_name.length > 1) {
      $.ajax({
        type: "get",
        url: pathname + "?last_name=" + last_name + "&first_name=" + first_name,
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