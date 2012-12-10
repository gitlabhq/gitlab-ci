GitlabCi::Application.routes.draw do
  # Optionally, enable Resque here
  require 'resque/server'
  mount Resque::Server => '/ext/resque', as: 'ext_resque'

  resources :projects do
    member do
      get :run
      get :status
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
  resource :resque, only: 'show'
  root :to => 'projects#index'
end
