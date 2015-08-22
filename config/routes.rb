Rails.application.routes.draw do

  # Api connection
  match '*path' => 'application#handle_options_request', :constraints => { method: 'OPTIONS'}, via: :options


  mount_devise_token_auth_for 'User', at: 'auth', except: [:omniauth_callbacks]

  resources :users, except: [:new, :edit]

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
