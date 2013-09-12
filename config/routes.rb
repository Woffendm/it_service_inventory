ITSI::Application.routes.draw do

  resources :portfolio_names


  resources :portfolios


  resources :product_priorities


  resources :products do
    member do
      post 'remove_from_portfolio'
      post 'remove_dependency'
      post 'remove_dependent'
    end
  end


  match '/404' => 'errors#page_not_found'
  match '/500' => 'errors#internal_server_error'
  match 'logout', :controller => :application, :action => :logout, :via => :get




  resources :groups do
    member do
      post 'add_employee'
      post 'toggle_group_admin'
      post 'remove_employee'
    end
    collection do
      get 'services'
    end
  end


  resources :employees do
    member do
      get 'user_settings'
      post 'update_settings'
      post 'toggle_active'
    end
    collection do
      get 'search_ldap_view'
      get 'ldap_search_results'
      get 'search_ldap'
      get 'search_ldap_view'
      post 'ldap_create'
      post 'update_all_employees_via_ldap'
    end
  end


  resources :app_settings do
    collection do
      get 'admins'
      post 'add_admin'
      post 'remove_admin'
      post 'update_settings'
    end
  end


  resources :product_states do
  end
  
  resources :product_types do
  end

  resources :fiscal_years do
  end

  resources :errors do
    collection do
      get 'internal_server_error'
      get 'invalid_credentials'
      get 'permission_denied'
      get 'page_not_found'
      get 'record_not_found'
    end
  end


  resources :logins do
    collection do
      get 'new_backdoor'
      get 'change_results_per_page'
      get 'change_year'
      get 'destroy'
      post 'create_backdoor'
    end
  end


  resources :pages do
    collection do
      get 'home_search'
      get 'home'
    end
  end


  resources :services do
    collection do 
      get 'groups'
    end
  end


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'pages#home'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
