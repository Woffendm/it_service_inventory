RedmineApp::Application.routes.draw do

  match 'lists/index' => 's2b_lists#index'
  match 'boards/index' => 's2b_boards#index'
  match 'boards/update_status' => 's2b_boards#update_status'
  match "boards/update_progress" => "s2b_boards#update_progress"
  match "lists/close_on_list" => "s2b_lists#close_on_list"
  match "boards/close_on_board" => "s2b_boards#close_on_board"
  match "boards/filter_issues_onboard" => "s2b_boards#filter_issues_onboard"
  match "lists/filter_issues_onlist" => "s2b_lists#filter_issues_onlist"
  match "boards/update" => "s2b_boards#update"
  match "lists/sort" => "s2b_lists#sort"
  match "boards/new" => "s2b_boards#new"
  match "boards/create" => "s2b_boards#create"
  match "lists/change_sprint" => "s2b_lists#change_sprint"

end