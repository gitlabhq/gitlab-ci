require 'sidekiq/web'

GitlabCi::Application.routes.draw do
  # API
  API::API.logger Rails.logger
  mount API::API => '/api'

  resources :projects do
    collection do
      post :add
      get :gitlab
    end

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

  resource :user_sessions
  resources :runners, only: [:index, :destroy]

  root :to => 'projects#index'
end
