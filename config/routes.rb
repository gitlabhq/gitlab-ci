GitlabCi::Application.routes.draw do
  resources :projects do
    resources :builds
  end

  devise_for :users
  root :to => 'projects#index'
end
