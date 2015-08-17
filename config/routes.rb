Rails.application.routes.draw do

 # Api connection
  match '*path' => 'application#handle_options_request', :constraints => { method: 'OPTIONS'}, via: :options


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
