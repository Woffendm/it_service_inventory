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
         'not_started'=> {
           'position' => '0', 'statuses' => {}
         }, 
         'in_progress' => {
           'position' => '1', 'statuses' => {}
         }, 
         'code_review' => {
           'position' => '2', 'statuses' => {}
         }, 
         'resolved' => {
           'position' => '3', 'statuses' => {}
         }, 
         'blocked' => {
           'position' => '4', 'statuses' => {}
         } 
       }, 
       'use_version_for_sprint' => 'true',
       'custom_field_id' => '' 
     }, :partial => 'settings/scrum2b'
  
  project_module :scrum2b do
    permission :view_issue, :s2b_lists => :index
    permission :view_issue, :s2b_boards => :index
  end
  menu :project_menu, :s2b_lists, { :controller => :s2b_lists, :action => :index }, :caption => :label_scrum2b, :after => :activity, :param => :project_id
 end


