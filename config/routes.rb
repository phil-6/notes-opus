Rails.application.routes.draw do
  # Authentication
  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[new create]

  # User preferences
  namespace :users do
    resource :preferences, only: :update
  end

  # Notes
  resources :notes do
    member do
      patch :pin
      patch :unpin
      patch :update_position
    end

    resources :shares, only: %i[create destroy], controller: "notes/shares"
    resources :versions, only: :index, controller: "notes/versions"
  end

  # Tags
  resources :tags, only: %i[index create destroy]

  # Connections
  resources :connections, only: %i[index create destroy]

  # Shared notes
  resources :shared_notes, only: :index

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  root "notes#index"
end
