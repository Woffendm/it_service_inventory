/**
* This file sets up tooltips throughout the application. Tooltips are text boxes that show up when
*    you hover over text, and provide additional information. 
*/
$(document).ready(function(){
  // .tooltip establishes the specified div as a tooltip and sets some custom positioning
  // .dynamic detects if the tooltip is displaying off the screen. If it is, then it corrects the 
  // tooltip's display so it is onscreen.
  $(".tooltip_trigger").tooltip({ offset : [-20, 50]
                        }).dynamic({ bottom : { direction : 'down', 
                                                bounce    : true } });
});