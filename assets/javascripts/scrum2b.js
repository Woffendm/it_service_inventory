$(document).ready(function(){ 
  
  
  $("#btn_filter").live("click",function(){
    var version_ids = $("#versions").val() || "";
    var status_ids = $("#statuses").val() || "";
    var custom_values = $("#custom_values").val() || "";
    var member_ids = $("#members").val() || "";
    var project_ids = $("#projects").val() || "";
    // url_filter must be defined on the view, as the path changes.
    $.ajax({
      url : url_filter,
      type : "POST",
      data : 'version_ids=' + version_ids + '&member_ids=' + member_ids + '&project_ids=' + project_ids + '&custom_values=' + custom_values + '&status_ids=' + status_ids,
      dataType : "script",
      success : function() {
        setup_sortable_columns();
        draw_progress_bars();
        calculate_time();
      }
    });
    return false;
  });
  
  
  
  function setup_sortable_columns() {
    var sortable_columns = $(".connectedSortable");
    var status;
    sortable_columns.sortable({
      // When dragging an element to an edge of the screen, will scroll at full speed
      scroll: true, scrollSensitivity: 100, scrollSpeed: 100,
      // Says where you can 'drop' the sortable elements
      connectWith: ".connectedSortable",
      // Says what part you can 'grab'
      handle: ".handle",
      // Triggered during sorting
      sort: function(){
        $(this).find(".ui-sortable-helper").addClass("check");
      },
      // Triggered when a connectedSortable list recieves an item from another list
      receive: function(){
        status = sortable_columns.index(this);
      },
      // Triggered when sorting has stopped
      stop: function() {
        var issue_id = $(".check").attr("id");
        var url_ajax = 'update_status';
        var id_next = $(".check").next().attr("id") || '';
        var id_prev = $(".check").prev().attr("id") || '';
        $(".check").removeClass("check");
        $.ajax({
          url : url_ajax,
          type : "POST",
          data : 'issue_id=' + issue_id + '&id_prev=' + id_prev + '&id_next=' + id_next + "&status=" + status,
          dataType : "json",
          success : function(data) {
            if (data.result != "success") {
              alert(data.message);
            }
          }
        });
      }
    });
  }
  
  
  
  function draw_progress_bars() {
    $(".slider-horizontal").each(function() {
      var id = parseInt($(this).parent().attr("value"));
      var slide_value = $(this).attr("value");
      makeSlider(id, slide_value);
    });
    
    $(".progressbar").each(function() {
      var id = parseInt($(this).parent().attr("value"));
      $("#progress"+id).progressbar({
        value:parseInt($(this).attr("value"))
       });
    });
  }
  
  
  
  $(".icon_edit_issue").live("click", function(){
    var issue_id = parseInt($(this).attr("issue_id"));
    var url_ajax = "edit";
    var edit = $("#edit_issue_" + issue_id);
    if (edit.html().length < 10) {
      $.ajax({
        url : url_ajax,
        type : "GET",
        data : 'issue_id=' + issue_id,
        dataType : "json",
        success : function(data) {
          if (data.result == "success") {
            edit.html(data.content);
            editDate(issue_id); 
          }
          else{
            alert(data.message);
          }
        }
      });
    }
    edit.show();
    $("#show_issue_" + issue_id).hide();
  });
  
  
  
  $(".cancel_issue").live("click", function(){
    var issue_id = parseInt($(this).parent().attr("value")) || "";
    $("#edit_issue_" + issue_id).hide();
    $("#show_issue_" + issue_id).show();
  });
 
 
 
  $(".submit_issue").live("click", function(){
    var issue_id = $(this).parent().attr("value");
    if(issue_id != "" ){
      var url_ajax = "update";
    }else {
       var url_ajax = "create";
    }
    var subject = $("#new_subject_"+issue_id).val() || "";
    var description = $("#new_description_"+issue_id).val() || "";
    var project = $("#new_project_"+issue_id).val() || "";
    var tracker = $("#new_tracker_"+issue_id).val() || "";
    var status = $("#new_status_"+issue_id).val() || "";
    var priority = $("#new_priority_"+issue_id).val() || "";
    var assignee = $("#new_assignee_"+issue_id).val() || "";
    var version = $("#new_version_"+issue_id).val() || "";
    var custom_value = $("#new_custom_value_"+issue_id).val() || "";
    var time = $("#new_time_"+issue_id).val() || "";
    var date_start = $("#new_date_start_"+issue_id).val() || "";
    var date_end = $("#new_date_end_"+issue_id).val() || "";
    var slide_value = $("#slider" + issue_id).attr("value");
    $.ajax({
      url : url_ajax,
      type : "POST",
      data : 'subject=' + subject + '&issue_id=' + issue_id + '&description=' + description + '&tracker=' + tracker + '&status=' + status + '&priority=' + priority + '&assignee=' + assignee + '&version=' + version + '&custom_value=' + custom_value + '&time=' + time + '&date_start=' + date_start + '&date_end=' + date_end + '&project=' + project,
      dataType : "json",
      success : function(data) {
        if(data.result == "edit_success") {
          $("#show_issue_" + issue_id).replaceWith(data.content).show();
          $("#edit_issue_" + issue_id).hide();
          makeSlider(issue_id, slide_value);
        }else if(data.result == "create_success"){
          $("#edit_issue_").find(".value_content").val("");
          $("#edit_issue_").hide();
          $("#edit_issue_").after(data.content);
          makeSlider(data.id, 0);
        }
        else{
          alert(data.message);
        }
      }
    });
  });
  
  
  
  $(".readmore").live("click", function(){
    var id = $(this).attr("value");
    $(this).hide();
    $("#hide_" + id).show();
    $("#description_readmore_" + id).show();
    $("#description_hide_" + id).hide();
     return false;

  });
  
  
  
  $(".hide").live("click", function() {
    var id = $(this).attr("value");
    $(this).hide();
    $("#readmore_" + id).show();
    $("#description_hide_" + id).show();
    $("#description_readmore_" + id).hide();
    return false;
  });
  
  
  
  $(".icon_new_issue").live("click", function(){
    $("#edit_issue_").show();
    $("#edit_issue_").addClass("board_issue");
  });
    
  
  
  function editDate(id){
    var start_date = $( "#new_date_start_" + id);
    var end_date = $( "#new_date_end_" + id);
    start_date.datepicker({
        defaultDate: start_date.attr("value"),
        dateFormat: "yy-mm-dd"
    });
    end_date.datepicker({
        defaultDate: end_date.attr("value"),
        dateFormat: "yy-mm-dd"
    });
  }
  
  
  
  function makeSlider(id, slide_value) {
    $("#slider" + id ).slider({
      orientation: "horizontal",
      range: "min",
      min: 0,
      max: 100,
      value: parseInt(slide_value),
      slide: function( event, ui ) {
        $("#amount"+id ).val( ui.value );
      },
      stop: function(e, ui) {
        var issue_id = parseInt($(this).parent().attr("value"));
        var url_ajax = "update_progress";
        $.ajax({
          url : url_ajax,
          type : "POST",
          data : 'done_ratio=' + ui.value + '&issue_id=' + issue_id,
          dataType : "json",
          success : function(res) {
            $("#slider" + issue_id).attr("value", ui.value);
          }
        });
      }
    });
    $("#amount" + id ).val( $("#slider" + id).slider("value"));
    $("#main-menu .s2b-lists").addClass("selected");
  }
  
  
  
  var chosen_selects = $(".chosen-select");
  $("#btn_clear").live("click", function () {
    chosen_selects.val('').trigger("chosen:updated");
  });
  
  
  
  function calculate_time() {
    $(".version_row").each(function() {
      var index = $(this).attr("index");
      var total = 0;
      var total_hours_div = $("#total_hours_" + index);
      var estimated_hours = $(".estimated_hours_" + index);
      estimated_hours.each(function() {
        var estimation = Number($(this).html());
        if(estimation) {
          total += estimation;
        }
      });
      total_hours_div.html(total);
    });
  }
  
  
  

  editDate("");   
  chosen_selects.chosen();
  draw_progress_bars();
  setup_sortable_columns();
  calculate_time();
  
  
  
});
