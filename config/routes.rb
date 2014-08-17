Rails.application.routes.draw do
  resources :supporters
  root 'pages#index'
  get '*path', to: 'supporters#show'
end
