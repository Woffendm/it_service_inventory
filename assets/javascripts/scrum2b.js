$(document).ready(function(){ 
  var chosen_selects = $(".chosen-select");
  
  chosen_selects.chosen();
  
  $("#btn_clear").live("click", function () {
    chosen_selects.val('').trigger("chosen:updated");
  });
});
