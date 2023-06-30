Rails.application.routes.draw do
  root 'homes#index'
  get 'homes/index'
  get 'samples/index'
end
