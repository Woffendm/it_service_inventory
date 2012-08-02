Project1::Application.routes.draw do


 match 'employees/home' => 'employees#home'
 match 'employees/search_ldap_view' => 'employees#search_ldap_view'
 match 'logins/new' => 'logins#new'
 match 'logins/new_backdoor' => 'logins#new_backdoor'
 match 'logins/destroy' => 'logins#destroy'
 match '/auth/:provider/callback' => 'logins#create'
 match 'logins/create_backdoor' => 'logins#create_backdoor'
 match 'app_settings/admins' => 'app_settings#admins'

  resources :groups do
    member do
      get 'roster'
      post 'add_employee'
      post 'remove_employee'
      post 'add_group_admin'
    end
    collection do
      get 'employees'
    end
  end
  
  resources :employees do
    member do
      get 'user_settings'
      post 'add_service'
      post 'remove_service'
      post 'update_settings'
    end
    collection do
      get 'populate_employee_results'
      get 'search_ldap'
      get 'ldap_search_results'
      post 'ldap_create'
      post 'update_all_employees_via_ldap'
    end
  end
  
  resources :app_settings do
    collection do
      post 'change_active_theme'
      post 'add_admin'
    end
  end
  
  resources :logins do
    collection do
      get 'change_results_per_page'
    end
  end
    
  
  resources :services
  

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
  root :to => 'employees#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
