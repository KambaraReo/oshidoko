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
      delete 'profiles/delete_icon', as: :delete_icon
      get 'confirm_withdrawal'
      resources :posts
    end
  end
end
