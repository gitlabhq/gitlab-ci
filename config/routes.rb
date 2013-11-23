require 'sidekiq/web'

GitlabCi::Application.routes.draw do

  resources :test_reports


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

      resources :coverages, only: [:show, :index]
      resources :report_files, only: [:show, :index]
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
