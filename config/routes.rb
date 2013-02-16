Wishme::Application.routes.draw do

  root :to => "home#index"

  # View routes
  get       'list/:sha1_id'       => 'list#show',                         :as => :list_show
  get       'item/:sha1_id'       => 'item#show',                         :as => :item_show

  # API routes
  post      'api/register'        => 'api/users/registrations#create',    :as => :users_registrations_create
  post      'api/login'           => 'api/users/sessions#create',         :as => :users_sessions_create
  post      'api/logout'          => 'api/users/sessions#destroy',        :as => :users_sessions_destroy

  post      'api/list/show'       => 'api/list/list#show',                :as => :list_list_show
  post      'api/list/show_all'   => 'api/list/list#show_all',            :as => :list_list_show_all
  post      'api/list/update'     => 'api/list/list#update',              :as => :list_list_update
  post      'api/list/delete'     => 'api/list/list#delete',              :as => :list_list_delete
  post      'api/list/clean'      => 'api/list/list#clean',               :as => :list_list_clean
  post      'api/list/create'     => 'api/list/list#create',              :as => :list_list_create

  post      'api/goggles/lookup'  => 'api/goggles/goggles#lookup',        :as => :goggles_goggles_lookup

  post      'api/item/create'     => 'api/item/item#create',              :as => :item_item_create
  post      'api/item/delete'     => 'api/item/item#delete',              :as => :item_item_delete
  post      'api/item/update'     => 'api/item/item#update',              :as => :item_item_update

  post      'api/category/all'    => 'api/category/category#show_all',    :as => :category_category_show_all

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
  #   restsources :products do
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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
