# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"
      post "auth/logout", to: "auth#logout"
      get "auth/me", to: "auth#me"

      patch "user", to: "user#update"
      delete "user", to: "user#destroy"

      resources :accounts, only: [:index, :show, :create, :update, :destroy]
      resources :categories, only: [:index, :show, :create, :update, :destroy]
      resources :transactions, only: [:index, :show, :create, :update, :destroy]
    end
  end
end
