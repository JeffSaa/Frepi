Rails.application.routes.draw do

  # Api cross Origin
  match '/api/v1/*path' => 'application#handle_options_request', constraints: { method: 'OPTIONS'}, via: :options

  # Devise
  mount_devise_token_auth_for 'User', at: '/api/v1/auth', skip: [:omniauth_callbacks]
  mount_devise_token_auth_for 'Supervisor', at: '/api/v1/auth_supervisor', skip: [:omniauth_callbacks]

  namespace :api do
    namespace :v1 do

      # Social network routes
      post 'auth/:provider/callback', to: 'sessions#create'

      resources :supervisors, except: [:new, :edit]

      resources :users, except: [:new, :edit] do
        resources :orders, except: [:new, :edit] do
          resources :schedules, except: [:new, :edit]
        end
      end

      namespace :shoppers, path: '' do
        get 'shoppers/in-store' => 'instore_shoppers#index'
        get 'shoppers/delivery' => 'delivery_shoppers#index'

        resources :shoppers, except: [:new, :edit] do
          resources :orders, except: [:new, :edit]
          # resources :schedules, except: [:new, :edit]
        end
      end

      namespace :administrator do

        resources :users, except: [:new, :edit]
        resources :products, except: [:new, :edit]
        resources :admins, only: :index

        namespace :statistics do
          resources :products, only: :index
          resources :shoppers, only: :index
          resources :earnings, only: :index
        end
      end

      namespace :supervisors, path: '' do
        namespace :orders do
          get 'delivering' => 'delivering#index'
          get 'dispatched' => 'dispatched#index'
          get 'received' => 'received#index'
          get 'shopping' => 'shopping#index'
          get 'disabled' => 'disabled#index'
          #post ':id/optimize' => 'optimized#create'
        end
        resources :orders, except: [:new, :edit]
      end

      resources :categories, except: [:new, :edit] do
        namespace :explorer, path: '' do
          resources :products, only: :index
        end
        resources :subcategories, except: [:new, :edit]
      end

      resources :store_partners, path: 'stores', except: [:new, :edit] do
        resources :sucursals, except: [:new, :edit] do
          resources :products, except: [:new, :edit]
        end
        resources :explore_categories, path: 'categories', only: :index
      end


      resources :countries, except: [:new, :edit] do
        resources :states, except: [:new, :edit] do
          resources :cities, except: [:new, :edit]
        end
      end

      namespace :search do
        resources :products, only: :index
      end

      resources :passwords, only: [:index, :create]

      # Explore
      get 'subcategories/:subcategory_id/products', to: 'explore_products#index'
    end
  end

end