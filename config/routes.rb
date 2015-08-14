Rails.application.routes.draw do

 # Api connection
  match '*path' => 'application#handle_options_request', :constraints => { method: 'OPTIONS'}, via: :options


  resources :products, :categories, :subcategories, except: [:new, :edit]
  resources :store_partners, path: 'stores'


  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

end
