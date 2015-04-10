Rails.application.routes.draw do
  root to: 'high_voltage/pages#show', id: 'home'

  devise_for :users

  resources :documents

  namespace :advocates do
    root to: 'claims#index'

    resources :claims do
      get 'summary', on: :member
      get 'confirmation', on: :member
    end

  end

  namespace :case_workers do
    root to: 'claims#index'

    resources :claims, only: [:index, :show]
  end
end
