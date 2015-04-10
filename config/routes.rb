Rails.application.routes.draw do
  root to: 'high_voltage/pages#show', id: 'home'

  devise_for :users

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

  namespace :admin do
    resources :users
  end
end
