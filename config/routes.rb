Rails.application.routes.draw do
  root 'homes#index'
  get 'homes/index'
  devise_for :users,
    controllers: { registrations: 'users/registrations' }
  resources :users, only: [:show] do
    collection do
      get 'edit_password'
      patch 'update_password'
      resources :profiles, only: [:edit, :update]
      get 'confirm_withdrawal'
      resources :posts, only: [:index, :new, :create, :destroy]
    end
  end
end
