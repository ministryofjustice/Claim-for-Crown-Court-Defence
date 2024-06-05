Rails.application.routes.draw do
  get 'dummy_exception', to: 'errors#dummy_exception'
  get 'ping',           to: 'heartbeat#ping', format: :json
  get 'healthcheck',    to: 'heartbeat#healthcheck',  as: 'healthcheck', format: :json

  match '(*any)', to: 'pages#servicedown', via: :all if Settings.maintenance_mode_enabled?

  get 'servicedown',    to: 'pages#servicedown',      as: :service_down_page
  get '/tandcs',        to: 'pages#tandcs',           as: :tandcs_page
  get '/vendor_tandcs', to: 'pages#vendor_tandcs',    as: :vendor_tandcs_page
  get '/contact_us',    to: 'pages#contact_us',       as: :contact_us_page
  get '/timed_retention', to: 'pages#timed_retention', as: :timed_retention_page
  get '/hardship_claims', to: 'pages#hardship_claims', as: :hardship_claims_page
  get '/api/landing',   to: 'pages#api_landing',      as: :api_landing_page
  get '/api/release_notes',   to: 'pages#api_release_notes', as: :api_release_notes
  get '/accessibility-statement', to: 'pages#accessibility_statement', as: :accessibility_statement

  get 'vat' => "vat_rates#index"

  get 'json_schemas/:schema', to: 'json_template#show', as: :json_schemas

  get '/404', to: 'errors#not_found', as: :error_404
  get '/500', to: 'errors#internal_server_error', as: :error_500

  devise_for :users, controllers: { sessions: 'sessions', passwords: 'passwords', unlocks: 'unlocks', registrations: 'external_users/registrations' }

  resources :users, only: :index

  authenticated :user, -> (u) { u.persona.is_a?(ExternalUser) } do
    root to: 'external_users/claims#index', as: :external_users_home
  end

  authenticated :user, -> (u) { u.persona.is_a?(CaseWorker) } do
    root to: 'case_workers/claims#index', as: :case_workers_home
  end

  authenticated :user, -> (u) { u.persona.is_a?(SuperAdmin) } do
    root to: 'super_admins/super_admins#show', as: :super_admins_home
    get 'super_admins/offences', to: 'super_admins/offences#index'

    require 'sidekiq/web'
    require 'sidekiq-scheduler/web'
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_scope :user do
    unauthenticated :user do
      root 'sessions#new', as: :unauthenticated_root
    end
  end

  mount API::Root => '/'
  mount GrapeSwaggerRails::Engine => '/api/documentation'

  resources :feedback, only: [:new, :create] do
    get '/', to: 'feedback#new', on: :collection
  end

  resources :claim_intentions, only: [:create], format: :json

  resources :documents do
    get 'download', on: :member
  end

  resources :messages, only: [:create]

  resources :establishments, only: %i[index], format: :js
  resources :offences, only: [:index], format: :js
  resources :case_types, only: [:show], format: :js
  resources :case_conclusions, only: [:index], format: :js

  resources :users, only: [] do
    put :settings, on: :member, action: :update_settings, format: :js
  end

  namespace :super_admins do
    root to: 'super_admins#show'

    get 'stats', to: 'stats#show'
    post 'stats', to: 'stats#show'

    namespace :admin do
      root to: 'super_admins#show'

      resources :super_admins, only: [:show, :edit, :update] do
        get 'change_password', on: :member
        patch 'update_password', on: :member
      end
    end
  end

  namespace :provider_management do
    root to: 'providers#index'
    get 'external_users/find', to: 'external_users#find'
    post 'external_users/find', to: 'external_users#search'

    resources :providers, except: [:destroy] do
      resources :external_users, except: [:destroy] do
        get 'change_password', on: :member
        patch 'update_password', on: :member
        get 'change_availability', on: :member
        patch 'update_availability', on: :member
      end
    end
  end

  scope module: 'external_users' do
    amend_actions = %i[new create edit update]
    namespace :advocates do
      resources :claims, only: amend_actions
      resources :supplementary_claims, only: amend_actions
      resources :hardship_claims, only: amend_actions
      resources :interim_claims, only: amend_actions
    end
    namespace :litigators do
      resources :claims, only: amend_actions
      resources :interim_claims, only: amend_actions
      resources :transfer_claims, only: amend_actions
      resources :hardship_claims, only: amend_actions
    end
  end

  namespace :external_users do
    root to: 'claims#index'

    resource :claim_types, only: [:new, :create]

    resources :claims, except: [:new, :create, :edit, :update] do
      get 'confirmation',           on: :member
      get 'summary',                on: :member
      get 'show_message_controls',  on: :member
      get 'outstanding',            on: :collection
      get 'authorised',             on: :collection
      get 'archived',               on: :collection
      get 'messages',               on: :member

      patch 'clone_rejected',       to: 'claims#clone_rejected',  on: :member
      patch 'unarchive',            to: 'claims#unarchive',       on: :member

      resource :certification, only: [:new, :create, :update]

      namespace :expenses do
        post 'calculate_distance', to: 'distances#create', as: :calculate_distance
      end

      namespace :fees do
        post 'calculate_price', to: 'prices#calculate'
      end
    end


    namespace :admin do
      root to: 'claims#index'

      resources :external_users do
        get 'change_password', on: :member
        patch 'update_password', on: :member
      end

      resources :providers, only: [:show, :edit, :update] do
        patch :regenerate_api_key, on: :member
      end
    end

  end

  namespace :case_workers do
    root to: 'claims#index'

    resources :claims, only: [:index, :show, :update] do
      get 'show_message_controls', on: :member
      get 'messages', on: :member
      get 'archived', on: :collection
      get 'download_zip', on: :member
    end

    namespace :admin do
      root to: 'allocations#new'

      resources :case_workers do
        get 'change_password', on: :member
        patch 'update_password', on: :member
      end

      resources :allocations, only: [:new, :create] do
        get '/', to: 'allocations#new', on: :collection
      end

      get 'management_information', to: 'management_information#index', as: :management_information
      get 'management_information/download', to: 'management_information#download', as: :management_information_download
      get 'management_information/generate', to: 'management_information#generate', as: :management_information_generate
      post 'management_information/create', to: 'management_information#create', as: :management_information_create
    end

  end

  resources :injection_attempts, only: [:dismiss] do
    patch 'dismiss', format: :js, on: :member
    put 'dismiss', format: :js, on: :member
  end

  post '/', to: 'errors#not_endpoint'

  resources :cookies, only: %i[new create], path: '/help/cookies' do
    get '/', to: 'cookies#new', on: :collection
  end
  get '/help/cookie-details', to: 'cookies#cookie_details'

  resource :csp_report, only: %i[create]

  # catch-all route
  # -------------------------------------------------
  # WARNING: do not put routes below this point
  unless Rails.env.development?
    match '*path', to: 'errors#not_found', via: :all
  end
end
