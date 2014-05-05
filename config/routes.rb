require 'sidekiq/web'

GitlabCi::Application.routes.draw do
  # API
  API::API.logger Rails.logger
  mount API::API => '/api'

  resource :help

  resources :projects do
    collection do
      post :add
      get :gitlab
    end

    member do
      get :status, to: 'projects#badge'
      get :integration
      post :build
    end

    resource :charts, only: [:show]

    resources :builds, only: [:show] do
      member do
        get :cancel
        get :status
        post :retry
      end
    end

    resources :web_hooks, only: [:index, :create, :destroy] do
      member do
        get :test
      end
    end
  end

  resource :user_sessions

  namespace :admin do
    resources :runners, only: [:index, :show, :update, :destroy] do
      member do
        put :assign_all
      end
    end

    resources :projects do
      resources :runner_projects
    end
  end

  root :to => 'projects#index'
end
