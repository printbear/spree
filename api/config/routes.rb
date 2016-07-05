Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :users do
      member do
        put :generate_api_key, to: redirect('/')
        put :clear_api_key, to: redirect('/')
      end
    end
  end

  namespace :api, :defaults => { :format => 'json' } do
    resources :products, only: [:index, :show] do
      resources :variants, only: [:index, :show]
      resources :product_properties, only: [:index, :show]
    end

    resources :images, only: [:index, :show]
    resources :checkouts, only: [:index, :show]

    resources :variants, only: [:index, :show]

    resources :option_types, only: [:index, :show] do
      resources :option_values, only: [:index, :show]
    end

    resources :orders, only: [:index, :show] do
      resources :addresses, only: [:show]

      resources :return_authorizations, only: [:index, :show]

      resources :line_items, only: [:index, :show, :update]
      resources :payments, only: [:index, :show]
    end

    resources :zones,     only: [:index, :show]
    resources :countries, only: [:index, :show]
    resources :states,    only: [:index, :show]

    resources :taxonomies, only: [:index, :show] do
      member do
        get :jstree
      end
      resources :taxons, only: [:index, :show] do
        member do
          get :jstree
        end
      end
    end
    resources :taxons, only: [:index]
    resources :inventory_units, only: [:show]
    resources :users, only: [:index, :show]
    resources :properties, only: [:index, :show]
    resources :stock_locations, only: [:index, :show] do
      resources :stock_movements, only: [:index, :show]
      resources :stock_items, only: [:index, :show]
    end
  end
end
