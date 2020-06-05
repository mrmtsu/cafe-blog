Rails.application.routes.draw do
  root 'static_pages#home'
  get :about,        to: 'static_pages#about'
  get :use_of_terms, to: 'static_pages#terms'
  get :signup,       to: 'users#new'
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :relationships, only: [:create, :destroy]
  resources :articles
  get    :login,     to: 'sessions#new'
  post   :login,     to: 'sessions#create'
  delete :logout,    to: 'sessions#destroy'
  get :favorites, to: 'favorites#index'
  post   "favorites/:article_id/create"  => "favorites#create"
  delete "favorites/:article_id/destroy" => "favorites#destroy"
  resources :comments, only: [:create, :destroy]
end
