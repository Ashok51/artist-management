Rails.application.routes.draw do
  get 'dashboard/index'
  devise_for :users, controllers: { registrations: 'registrations' }
  resources :added_users


  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "added_users#index"

  resources :artists do
    collection do
      post :import
      get :export, format: :csv
    end
  end

  resources :musics
end
