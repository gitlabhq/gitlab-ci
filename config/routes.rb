require 'sidekiq/web'

GitlabCi::Application.routes.draw do
  # Optionally, enable Resque here
  constraint = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin? }
  constraints constraint do
    mount Sidekiq::Web, at: "/ext/sidekiq", as: :ext_resque
  end

  # API
  require 'api'
  GitlabCi::API.logger Rails.logger
  mount GitlabCi::API => '/api'

  resources :projects do
    member do
      get :run
      get :status
      get :stats
      get :details
      post :build
    end

    resources :builds, only: [:show] do
      member do
        get :cancel
        get :status
      end
    end
  end

  devise_for :users, controllers: { omniauth_callbacks: :omniauth_callbacks }

  resources :users do
    member do
      put :reset_private_token
    end
  end
  resource :resque, only: 'show'
  root :to => 'projects#index'
end
