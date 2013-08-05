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
      get :charts
      get :integration
      post :build
    end

    resources :builds, only: [:show] do
      member do
        get :cancel
        get :status
        post :retry
      end
    end

    resources :runner_projects
  end

  resource :user_sessions
  resources :runners, only: [:index, :update, :destroy] do
    member do
      put :assign_all
    end
  end

  root :to => 'projects#index'
end
