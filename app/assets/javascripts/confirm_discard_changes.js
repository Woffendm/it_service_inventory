/**
*  This sets up warnings for forms to remind the user to save their changes before switching pages.
*     The warnings are activated when the user changes any input and are disabled when the user 
*     submits. This feature is enabled on every page by default, and can be disabled by setting a
*     javascript variable do_not_check_for_changes to true in the desired view.
*/
$(document).ready(function(){
  
  // Binds event
  $('input, select').change(function(){
    if(typeof do_not_check_for_changes == 'undefined'){
      window.onbeforeunload = function(e) {
        return "You have unsaved changes. Are you sure you want to leave?";
      };
    }
  });
  
  
  // Unbinds event
  $('form').submit(function() {
    window.onbeforeunload = null;
  });
});