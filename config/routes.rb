require 'sidekiq/web'

Rails.application.routes.draw do
  # API
  API::API.logger Rails.logger
  mount API::API => '/api'

  resource :lint, only: [:show, :create]

  resource :help do
    get :oauth2
  end

  resources :projects do
    collection do
      post :add
      get :gitlab
    end

    member do
      get :status, to: 'projects#badge'
      get :integration
      post :build
      post :toggle_shared_runners
      get :dumped_yaml
    end

    resources :services, only: [:index, :edit, :update] do
      member do
        get :test
      end
    end

    resource :charts, only: [:show]

    resources :refs, constraints: { ref_id: /.*/ }, only: [] do
      resources :commits, only: [:show] do
        member do
          get :status
          get :cancel
        end
      end
    end

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

    resources :triggers, only: [:index, :create, :destroy]

    resources :runners, only: [:index, :edit, :update, :destroy, :show] do
      member do
        get :resume
        get :pause
      end
    end

    resources :runner_projects, only: [:create, :destroy]

    resources :events, only: [:index]
    resource :variables, only: [:show, :update]
  end

  resource :user_sessions do
    get :auth
    get :callback
  end

  namespace :admin do
    resources :runners, only: [:index, :show, :update, :destroy] do
      member do
        put :assign_all
        get :resume
        get :pause
      end
    end

    resources :events, only: [:index]

    resources :projects do
      resources :runner_projects
    end

    resources :builds, only: :index

    resource :application_settings, only: [:show, :update]
  end

  root to: 'projects#index'
end
