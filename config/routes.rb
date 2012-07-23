Project1::Application.routes.draw do


 match 'employees/home' => 'employees#home'
 match 'employees/search_ldap_view' => 'employees#search_ldap_view'
 match 'logins/new' => 'logins#new'
 match 'logins/create' => 'logins#create'
 match 'logins/destroy' => 'logins#destroy'

 
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
      post 'add_service'
      post 'remove_service'
    end
    collection do
      get 'populate_employee_results'
      get 'search_ldap'
      get 'ldap_search_results'
      post 'ldap_create'
    end
  end
  
  resources :app_settings do
    collection do
      post 'change_active_theme'
    end
  end
  
  resources :logins
  
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