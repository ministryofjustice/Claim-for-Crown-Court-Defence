Rails.application.routes.draw do

  get 'ping',           to: 'heartbeat#ping', format: :json
  get 'healthcheck',    to: 'heartbeat#healthcheck',  as: 'healthcheck', format: :json
  get '/tandcs',        to: 'pages#tandcs',           as: :tandcs_page
  get '/api_landing',   to: 'pages#api_landing',      as: :api_landing_page
  get '/contact_us',    to: 'pages#contact_us',       as: :contact_us_page

  get 'vat'                 => "vat_rates#index"

  get 'json_schema' => 'json_template#index'

  get '/404', to: 'errors#not_found', as: :error_404
  get '/500', to: 'errors#internal_server_error', as: :error_500

  devise_for :users, controllers: { sessions: 'sessions', passwords: 'passwords', registrations: 'advocates/registrations' }

  authenticated :user, -> (u) { u.persona.is_a?(Advocate) } do
    root to: 'advocates/claims#index', as: :advocates_home
  end

  authenticated :user, -> (u) { u.persona.is_a?(CaseWorker) } do
    root to: 'case_workers/claims#index', as: :case_workers_home
  end

  devise_scope :user do
    unauthenticated :user do
      root 'sessions#new', as: :unauthenticated_root
    end
  end

  mount API::Root => '/'
  mount GrapeSwaggerRails::Engine => '/api/documentation'

  resources :claim_intentions, only: [:create], format: :json

  resources :documents do
    get 'download', on: :member
  end

  resources :messages, only: [:create] do
    get 'download_attachment', on: :member
  end

  resources :offences, only: [:index], format: :js

  resources :user_message_statuses, only: [:index, :update]

  namespace :advocates do
    root to: 'claims#index'

    resources :json_document_importers, only: [:create], format: :js

    post '/advocates/json_importer' => 'json_document_importer#create'

    resources :claims do
      get 'confirmation', on: :member
      get 'outstanding',  on: :collection
      get 'authorised',   on: :collection
      get 'archived',     on: :collection

      resource :certification, only: [:new, :create]
    end

    namespace :admin do
      root to: 'claims#index'

      resources :advocates do
        get 'change_password', on: :member
        patch 'update_password', on: :member
      end
    end

  end

  namespace :case_workers do
    root to: 'claims#index'

    resources :claims, only: [:index, :show, :update] do
    get 'archived', on: :collection
    end

    namespace :admin do
      root to: 'allocations#new'

      resources :case_workers do
        get 'allocate', on: :member
        get 'change_password', on: :member
        patch 'update_password', on: :member
      end

      resources :allocations, only: [:new, :create] do
        get '/', to: 'allocations#new', on: :collection
      end
    end
  end

  namespace :geckoboard_api, format: :json do
    get 'widgets/claims', to: 'widgets#claims'
    get 'widgets/claim_completion', to: 'widgets#claim_completion'
  end
end
