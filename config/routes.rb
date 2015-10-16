Rails.application.routes.draw do

 # Api connection
  match '*path' => 'application#handle_options_request', constraints: { method: 'OPTIONS' }, via: :options

  # Social network routes
  post 'auth/:provider/callback', to: 'sessions#create'

  # Devise
  mount_devise_token_auth_for 'User', at: 'auth', skip: [:omniauth_callbacks]
  mount_devise_token_auth_for 'Shopper', at: 'auth_shopper', skip: [:omniauth_callbacks]

  resources :users, except: [:new, :edit] do
    resources :orders, except: [:new, :edit] do
      resources :schedules, except: [:new, :edit]
    end
  end

  namespace :shoppers, path: '' do
    resources :shoppers, except: [:new, :edit] do
      resources :orders, except: [:new, :edit]
      resources :schedules, except: [:new, :edit]
    end
  end

  namespace :orders, path: '' do
    resources :orders, only: :index
  end

  resources :categories, except: [:new, :edit] do
    resources :subcategories, except: [:new, :edit]
  end

  resources :store_partners, path: 'stores', except: [:new, :edit] do
    resources :sucursals, except: [:new, :edit] do
      resources :products, except: [:new, :edit]
    end
  end

  resources :countries, except: [:new, :edit] do
    resources :states, except: [:new, :edit] do
      resources :cities, except: [:new, :edit]
    end
  end
end