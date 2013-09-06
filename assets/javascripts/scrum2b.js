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
    sortable_columns.sortable({
      scroll: true, scrollSensitivity: 100, scrollSpeed: 100,
      connectWith: ".connectedSortable",
      sort: function(){
        $(this).find(".ui-sortable-helper").addClass("check");
      },
      receive: function(){
        var status = sortable_columns.index(this);
        var url_ajax = 'update_status';
        var issue_id = $(this).find(".check").attr("id");
        $.ajax({
          url : url_ajax,
          type : "POST",
          data : 'issue_id=' + issue_id + '&status=' + status,
          dataType : "json",
          success : function(res) {
            if (res.status == "completed"){
              makeSlider(issue_id, res.done_ratio);
            }
          }
        });
      },
      stop: function() {
        var issue_id = $(".check").attr("id");
        // url_sort must be defined in the view
        var id_next = $(".check").next().attr("id");
        var id_prev = $(".check").prev().attr("id");
        $(".check").removeClass("check");
        $.ajax({
          url : url_sort,
          type : "POST",
          data : 'issue_id=' + issue_id + '&id_prev=' + id_prev + '&id_next=' + id_next,
          dataType : "text",
          success : function(){}
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
    var id_issue = parseInt($(this).parent().attr("value"));
    $(".icon_edit_issue").show();
    $(this).hide();
    $("#completed").find(".icon_close_issue").show();
    $("#close_"+id_issue).hide();
    $(".editing").hide();
    $(".no_edit").show();
    $("#edit_issue_" + id_issue).show();
    $("#show_issue_" + id_issue).hide();
    $(".hide").hide();
  });
  
  
  $(".cancel_issue").live("click", function(){
    var id_issue = parseInt($(this).parent().attr("value"));
    $("#completed").find("#close_" + id_issue).show();
    $("#edit_issue_"+id_issue).hide();
    $("#show_issue_"+id_issue).show();
    $(".icon_edit_issue").show();
    $(".readmore").show();
    $(".hide").hide();
    $(".description_readmore").hide();
    $("#edit_issue_").hide();
  });
 
 
  $(".submit_issue").live("click", function(){
    var id_issue = $(this).parent().attr("value");
    if(id_issue != "" ){
      var url_ajax = "update";
    }else {
       var url_ajax = "create";
    }
    var subject = $("#new_subject_"+id_issue).val() || "";
    var description = $("#new_description_"+id_issue).val() || "";
    var project = $("#new_project_"+id_issue).val() || "";
    var tracker = $("#new_tracker_"+id_issue).val() || "";
    var status = $("#new_status_"+id_issue).val() || "";
    var priority = $("#new_priority_"+id_issue).val() || "";
    var assignee = $("#new_assignee_"+id_issue).val() || "";
    var version = $("#new_version_"+id_issue).val() || "";
    var custom_value = $("#new_custom_value_"+id_issue).val() || "";
    var time = $("#new_time_"+id_issue).val() || "";
    var date_start = $("#new_date_start_"+id_issue).val() || "";
    var date_end = $("#new_date_end_"+id_issue).val() || "";
    var slide_value = $("#slider" + id_issue).attr("value");
    $.ajax({
      url : url_ajax,
      type : "POST",
      data : 'subject=' + subject + '&id_issue=' + id_issue + '&description=' + description + '&tracker=' + tracker + '&status=' + status + '&priority=' + priority + '&assignee=' + assignee + '&version=' + version + '&custom_value=' + custom_value + '&time=' + time + '&date_start=' + date_start + '&date_end=' + date_end + '&project=' + project,
      dataType : "json",
      success : function(data) {
        if(data.result == "edit_success") {
          $("#show_issue_" + id_issue).replaceWith(data.content).show();
          makeSlider(id_issue, slide_value);
          $("#edit_issue_" + id_issue).replaceWith(data.edit_content).hide();
          editDate(id_issue); 
          form_edit(id_issue);
          $("#completed").find(".icon_close_issue").show();
        }else if(data.result == "create_success"){
          $("#edit_issue_").find(".value_content").val("");
          $("#edit_issue_").hide();
          $("#edit_issue_").after(data.content);
          makeSlider(data.id,0);
          editDate(data.id); 
          form_edit(data.id);
        }
        else{
          alert(data.message);
        }
      }
    });
  });
  
  
  $(".editing").each(function() {
    var id = $(this).attr("value");
    editDate(id);
    if( id != ""){ 
      form_edit(id);
    }      
  })
  
  
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
  
  
  var start_date = $( "#date_start_");
  start_date.datepicker({
    defaultDate: start_date.attr("value"),
    dateFormat: "yy-mm-dd"
  });
  
  
  var end_date = $( "#date_end_");
  end_date.datepicker({
    defaultDate: end_date.attr("value"),
    dateFormat: "yy-mm-dd"
  });
  
  
  
  $(".icon_new_issue").live("click", function(){
    $("#edit_issue_").show();
    $("#edit_issue_").addClass("board_issue");
  });
    
  
  
  function form_edit(id){
    $("#p_status_" + id).hide();
    $("#p_priority_" + id).hide();
    $("#p_tracker_" + id).hide();
    $("#p_sprint_" + id).hide(); 
    $("#p_project_" + id).hide(); 
  }
  
  
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
  
  
  chosen_selects.chosen();
  draw_progress_bars();
  setup_sortable_columns();
  calculate_time();
  
  
  
});
