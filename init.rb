require 'redmine'
Redmine::Plugin.register :scrum2b do
  name 'Scrum2B Plugin'
  author 'Scrum2B'
  description %Q{A scrum tool for team to work:
                  - Scrum board
                  - Customize views
                }
  version '0.1'
  url 'https://github.com/scrum2b/scrum2b'
  author_url 'http://scrum2b.com'

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
       'use_version_for_sprint' => 'true',
       'custom_field_id' => '',
       'current_sprint' => '' 
     }, :partial => 'settings/scrum2b'
  
  project_module :scrum2b do
    permission :view_issue, :s2b_lists => :index
    permission :view_issue, :s2b_boards => :index
  end
  menu :project_menu, :s2b_lists, { :controller => :s2b_lists, :action => :index }, :caption => :label_scrum2b, :after => :activity, :param => :project_id
 end


