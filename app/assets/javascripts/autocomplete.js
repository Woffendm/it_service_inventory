/**
* This file sets up hybrid autocomplete-select boxes throughout the application. You can either use
*    it like a regular select box, or type stuff in. Nifty!
*/
jQuery(document).ready(function(){
  jQuery(".autocomplete").select2({
    width: 200
  });
});