require 'sidekiq/web'

GitlabCi::Application.routes.draw do
  # Optionally, enable Resque here
  constraint = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin? }
  constraints constraint do
    mount Sidekiq::Web, at: "/ext/sidekiq", as: :ext_resque
  end

  match "/auth/:provider/callback", to: "omniauth_callbacks#create"
  match "/auth/failure" => redirect("/users/sign_in")

  resources :github_projects, only: [:new,:create,:index] do
    member do
      post :regenerate
    end
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

  resources :users
  resource :resque, only: 'show'
  root :to => 'projects#index'
end
