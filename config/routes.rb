Rails.application.routes.draw do
  scope '/weather' do
	get 'locations', to: 'location#locations', as: :locations, defaults: {format: :json}
	get 'data/:postcode/:date', constraints: {postcode: /3[0-9]{3}/.freeze}, to: 'data#data_postcode', defaults: {format: :json}
	get 'data/:location_id/:date', to: 'data#data_location_id', constraints: {postcode: /3[0-9]{3}/.freeze}, defaults: {format: :json}
	get 'prediction/:lat/:long/:period', to: 'prediction#prediction', constraints: {lat: /-?\d+(.\d+)?/.freeze, long: /-?\d+(.\d+)?/.freeze},defaults: {format: :json}
	get 'prediction/:postcode/:period', to: 'prediction#prediction', defaults: {format: :json}
  end
  root 'weather#index'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
