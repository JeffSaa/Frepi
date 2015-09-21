Rails.application.routes.draw do

  # Api connection
  match '*path' => 'application#handle_options_request', :constraints => { method: 'OPTIONS'}, via: :options

  # Devise
  mount_devise_token_auth_for 'User', at: 'auth', skip: [:omniauth_callbacks]

  as :shopper do
    # Define routes for Shopper within this block.
  end

  post 'auth/:provider/callback', to: 'sessions#create'

  resources :users, except: [:new, :edit] do
    resources :orders, except: [:new, :edit]
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
