/**
* This file sets up tooltips throughout the application. Tooltips are text boxes that show up when
*    you hover over text, and provide additional information. 
*/
$(document).ready(function(){
  // .tooltip establishes the specified div as a tooltip and sets some custom positioning
  // .dynamic detects if the tooltip is displaying off the screen. If it is, then it corrects the 
  // tooltip's display so it is onscreen.
  var tooltip_triggers = $(".tooltip_trigger");
  var tooltip_contents = $(".tooltip");
  
  
  tooltip_triggers.each(function(e) {
    var index = tooltip_triggers.index(this);
    tooltip_contents[index].setAttribute("id", "tooltip-content-" + index);
  });
  
  
  $(".tooltip_trigger").popover({
    html: true,
    content: function() {
      return $("#tooltip-content-" + tooltip_triggers.index(this)).html();
    }
  });
});