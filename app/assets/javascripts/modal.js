/**
* This file sets up modals throughout the application sensation that's sweeping the nation
* For pages with just one modal (or share the same modal), the tag modal_content id and 
* modal_trigger class are used. For pages with multiple modals, the modal_content_2 and 
* modal_trigger_2 classes are used. 
*/
$(document).ready(function(){
  if( $("#modal_content")[0] != undefined) {
    // Sets the specified content to be a modal, and also sets some options for it. 
    $("#modal_content").dialog({ 
      autoOpen  : false,
      width     : 740,
      modal     : true,
      title     : modalTitle,
      show      : "drop"
    });
    
    
    
    // Opens the shared modal content
    $(".modal_trigger").click(function(e){ 
      $("#modal_content").dialog("open");
    });
  }
  
  
  
  if( $(".modal_content_2")[0] != undefined) {
    // Sets the specified content to be a modal, and also sets some options for it. 
    $(".modal_content_2").dialog({ 
      autoOpen  : false,
      width     : 740,
      modal     : true,
      title     : modalTitle2,
      show      : "drop"
    });
    
    
    
    // Opens the unique modal content for that trigger
    $(".modal_trigger_2").click(function(e){ 
      $("#modal_content_" + $(".modal_trigger_2").index(this)).dialog("open");
    });
  }
});
