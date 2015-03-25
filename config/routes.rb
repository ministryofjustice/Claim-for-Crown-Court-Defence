Rails.application.routes.draw do
  devise_for :case_workers
  devise_for :advocates
end
