Rails.application.routes.draw do
  root to: 'high_voltage/pages#show', id: 'home'

  devise_for :case_workers
  devise_for :advocates

  resources :claims
end
