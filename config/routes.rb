Rails.application.routes.draw do
  root 'homes#index'
  resources :homes, only: [:index] do
    get 'search', on: :collection
  end
  resources :contacts, only: [:new, :create] do
    collection do
      post 'confirm'
      post 'back'
      get 'done'
    end
  end
  devise_scope :user do
    post 'users/guest_sign_in', to: 'users/sessions#guest_sign_in'
  end
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    passwords: 'users/passwords',
  }
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
        resource :favorite, only: [:create, :destroy, :show]
        resources :comments, only: [:create, :destroy]
      end
    end

    member do
      get 'favorites'
      get 'follows'
      get 'followers'
    end
    resource :relationships, only: [:create, :destroy]
  end
end
