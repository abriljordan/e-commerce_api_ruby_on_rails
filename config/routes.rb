Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      # Authentication routes
      post 'auth/login', to: 'authentication#login'
      post 'auth/register', to: 'authentication#register'
      post 'auth/refresh', to: 'authentication#refresh'
      post 'auth/forgot_password', to: 'authentication#forgot_password'
      post 'auth/reset_password', to: 'authentication#reset_password'
      post 'auth/logout', to: 'auth#logout'

      # Public resources
      resources :products, only: [:index, :show] do
        collection do
          get :search
        end
        resources :reviews, controller: 'product_reviews', only: [:index, :show, :create, :update, :destroy]
        get 'reviews/statistics', to: 'review_statistics#show'
      end
      resources :categories, only: [:index, :show]
      resources :sub_categories, only: [:index, :show]
      resources :cart_items, only: [:create, :update, :destroy]
      resources :addresses, only: [:index, :show, :create, :update, :destroy]
      resources :orders, only: [:index, :show, :create] do
        member do
          post :cancel
        end
      end
      resources :wishlists, only: [:index, :create, :destroy]

      # Admin namespace
      namespace :admin do
        get 'dashboard/statistics', to: 'dashboard#statistics'
        
        resources :products do
          member do
            post :toggle_active
            post :toggle_featured
          end
          collection do
            get :low_stock
            get :out_of_stock
          end
        end
        
        resources :orders do
          member do
            post :cancel
            post :fulfill
            post :ship
          end
          collection do
            get :statistics
          end
        end
        
        resources :users do
          member do
            post :toggle_admin
          end
          collection do
            get :statistics
          end
        end
        
        resources :categories do
          resources :sub_categories
        end

        resources :products do
          resources :reviews, controller: 'product_reviews' do
            member do
              post :approve
              post :reject
            end
            collection do
              get :pending
            end
          end
        end

        get 'reviews/analytics', to: 'review_analytics#index'
      end

      get 'reviews/recommendations', to: 'review_recommendations#index'
    end
  end

  # Swagger documentation
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'
end
