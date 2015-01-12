Hippocampus::Application.routes.draw do
  root :to => "sessions#new"

  get "login", :to => "sessions#new", :as => "login"
  post 'session/:phone', :to => "sessions#create", :as => "create_session"
  get 'logout', :to => "sessions#destroy", :as => "logout"
  match 'passcode', :to => "sessions#passcode", :as => "passcode"

  resources :buckets, :only => [:create, :update, :destroy]
  
  resources :bucket_item_pairs, :only => [:create, :destroy]

  resources :emails, :only => [:create]
  
  resources :items, :only => [:create, :update, :destroy, :show, :edit, :new]

  get 'search', to: 'pages#search', as: 'search'
  
  resources :sms, :only => [:create]

  resources :users, :except => [:index, :new, :create]
  get 'users/:id/items', to: 'users#items'
  get 'users/:id/buckets', to: 'users#buckets'
  
end
