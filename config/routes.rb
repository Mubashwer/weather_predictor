Rails.application.routes.draw do
  DECIMAL_PATTERN = /-?\d+(.\d+)?/.freeze
  POSTCODE_CONSTRAINT = /3[0-9]{3}/.freeze
  scope '/weather' do
	get 'locations', to: 'weather#locations', defaults: {format: :json}
	get 'data/:postcode/:date', constraints: {postcode: POSTCODE_CONSTRAINT}, to: 'weather#data_postcode', defaults: {format: :json}
	get 'data/:location_id/:date', to: 'weather#data_location_id', constraints: {postcode: POSTCODE_CONSTRAINT}, defaults: {format: :json}
	get 'prediction/:lat/:long/:period', to: 'weather#prediction', constraints: {lat: DECIMAL_PATTERN, long: DECIMAL_PATTERN},defaults: {format: :json}
	get 'prediction/:postcode/:period', to: 'weather#prediction', defaults: {format: :json}
  end

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
