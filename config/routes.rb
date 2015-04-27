Rails.application.routes.draw do
  
  root to: 'high_voltage/pages#show', id: 'home'

  namespace :api, format: :json do
    namespace :advocates do
      resources :claims
    end
  end

  devise_for :users

  resources :documents do
    get 'download', on: :member
  end

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
    root to: 'users#index'

    resources :users do
      get 'allocate', on: :member
    end
  end
end
