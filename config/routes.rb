require 'sidekiq/web'

GitlabCi::Application.routes.draw do
  # Optionally, enable Resque here
  constraint = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin? }
  constraints constraint do
    mount Sidekiq::Web, at: "/ext/sidekiq", as: :ext_resque
  end

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

  devise_for :users
  devise_scope :user do
    get '/login'    => 'devise/sessions#new',        as: 'user_login'
    get '/logout'   => 'devise/sessions#destroy',    as: 'user_logout'
    get '/forgot'   => 'devise/passwords#new',       as: 'user_forgot_password'
  end

  resources :users
  resource :resque, only: 'show'
  root to: 'projects#index'
end
