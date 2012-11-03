GitlabCi::Application.routes.draw do
  # Optionally, enable Resque here
  require 'resque/server'
  mount Resque::Server => '/resque', as: 'resque'

  resources :projects do
    member do
      get :run
      post :build
    end
    resources :builds
  end

  devise_for :users

  resources :users
  root :to => 'projects#index'
end
