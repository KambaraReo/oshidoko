Rails.application.routes.draw do
  root 'homes#index'
  get 'homes/index'
  devise_for :users,
    controllers: { registrations: 'users/registrations' }
  resources :users, only: [:show] do
    collection do
      get 'mypage'
      get 'edit_password'
      patch 'update_password'
      get 'confirm_withdrawal'
      resources :profiles, only: [:edit, :update]
      delete 'profiles/delete_icon', as: :delete_icon
      resources :posts, except: [:index]
    end
  end
end
