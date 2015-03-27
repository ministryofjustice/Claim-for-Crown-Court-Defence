Rails.application.routes.draw do
  root to: 'high_voltage/pages#show', id: 'home'

  devise_for :users

  namespace :advocates do
    root to: 'dashboard#index'
  end

  namespace :case_workers do
    root to: 'dashboard#index'
  end

  resources :claims
end
