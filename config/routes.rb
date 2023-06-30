Rails.application.routes.draw do
  get 'users/index'
  devise_for :users
  root 'homes#index'
  get 'homes/index'
  get 'samples/index'
end
