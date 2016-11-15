Rails.application.routes.draw do
  resources :supporters, only: [:index, :show, :new, :create, :edit, :update]
  resource :email, only: [:create, :show]
  get '/edit', to: 'emails#new'

  root 'pages#index'
  get '*path', to: 'supporters#show'
end
