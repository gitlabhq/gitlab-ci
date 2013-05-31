require 'sidekiq/web'

GitlabCi::Application.routes.draw do
  # Optionally, enable Resque here
  constraint = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin? }
  constraints constraint do
    mount Sidekiq::Web, at: "/ext/sidekiq", as: :ext_resque
  end

  # API
  API::API.logger Rails.logger
  mount API::API => '/api'

  resources :projects do
    member do
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

  devise_for :users

  resources :users
  resources :runners, only: [:index, :destroy]

  resource :resque, only: 'show'
  root :to => 'projects#index'
end
