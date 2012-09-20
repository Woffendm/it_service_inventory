/**
* This file sets up modals throughout the application sensation that's sweeping the nation
*/
$(document).ready(function(){
  if( $("#modal_content")[0] != undefined) {
    // Sets the specified content to be a modal, and also sets some options for it. 
    $("#modal_content").dialog({ 
      autoOpen  : false,
      width     : "auto",
      modal     : true,
      title     : modalTitle,
      show      : "drop"
    });
    
    
    
    // Opens the modal content
    $(".modal_trigger").click(function(e){ 
      $("#modal_content").dialog("open");
    });
  }
});
