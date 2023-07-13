Rails.application.routes.draw do
  get 'samples/index'
  root 'homes#index'
  get 'homes/index'
  devise_for :users,
    controllers: { registrations: 'users/registrations' }
  resources :users, only: [:index, :show] do
    collection do
      get 'edit_password'
      patch 'update_password'
      resources :profiles, only: [:edit, :update]
      get 'confirm_withdrawal'
    end
  end
end
