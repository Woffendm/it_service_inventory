require 'redmine'

Redmine::Plugin.register :scrum2b do
  name 'Scrum2B Plugin'
  author 'Scrum2B, Michael Woffendin'
  description %Q{A scrum tool for team to work:
                  Scrum board
                  Customize views
                }

  version '1.1.0'
  url 'https://github.com/scrum2b/scrum2b'


  settings :default => {
    'board_columns' => {
      '0'=> {
        'position' => '1', 'name' => 'Not Started', 'statuses' => {}
      }, 
      '1' => {
        'position' => '2', 'name' => 'In Progress', 'statuses' => {}
      }, 
      '2' => {
        'position' => '3', 'name' => 'Code Review', 'statuses' => {}
      }, 
      '3' => {
        'position' => '4', 'name' => 'Resolved', 'statuses' => {}
      }, 
      '4' => {
        'position' => '5', 'name' => 'Blocked', 'statuses' => {}
      } 
    }, 
    'sprint' => {
      'use_default'      => 'true',
      'custom_field_id'  => '',
      'current_sprint'   => ''
    },
    'priority' => {
      'use_default'      => 'true',
      'custom_field_id'  => ''
    },
    'assignee' => {
      'use_default'      => 'true',
      'custom_field_id'  => ''
    },
    'show_progress_bars' => 'true'
  }, 
  :partial => 'settings/scrum2b'
  
  project_module :scrum2b do

  end
  
  menu :project_menu, :scrum_board, { :controller => :s2b_lists, :action => :index }, :caption => "Sprint Board", :after => :activity, :param => :project_id
  
  menu :top_menu, :scrum_board, { :controller => :s2b_lists, :action => :index }, :caption => "Sprint Board"
  
end



Rails.configuration.to_prepare do
  require_dependency 'issue'
  require_dependency 'issue_patch'
  Issue.send(:include, IssuePatch)
end



