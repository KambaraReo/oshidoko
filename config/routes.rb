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
      resource :profile, only: [:edit, :update] do
        delete 'delete_icon', on: :collection
      end
      resources :posts, except: [:index] do
        resource :favorite, only: [:create, :destroy, :show] do
        end
      end
    end

    get 'favorites', on: :member
  end
end
