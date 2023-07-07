Rails.application.routes.draw do
  get 'samples/index'
  root 'homes#index'
  get 'homes/index'
  get 'users/edit_password'
  patch 'users/update_password'
  devise_for :users,
    controllers: { registrations: 'users/registrations' }
  resources :users, only: [:index, :show]
end
