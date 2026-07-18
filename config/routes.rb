Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :orders, only: %i[create] do
    member do
      post :complete
      post :cancel
    end
  end

  namespace :auth do
    post "sign_up",    to: "registrations#create"
    post "sign_in",    to: "sessions#create"
    delete "sign_out", to: "sessions#destroy"
  end
end
