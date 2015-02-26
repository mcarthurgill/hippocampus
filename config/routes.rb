Hippocampus::Application.routes.draw do

  root :to => "introductions#show"
    
  get "login", :to => "sessions#new", :as => "login"
  post 'session/:phone', :to => "sessions#create", :as => "create_session"
  post 'session', :to => "sessions#create"
  get 'logout', :to => "sessions#destroy", :as => "logout"
  match 'passcode', :to => "sessions#passcode", :as => "passcode"
  
  match 'next', :to => "introductions#next", :as => "next"
  match 'fail', :to => "introductions#fail", :as => "fail"
  match 'intro_questions', :to => "introductions#get_questions", :as => "get_intro_questions"

  resources :buckets, :only => [:show, :new, :edit, :create, :update, :destroy]
  
  resources :bucket_item_pairs, :only => [:create, :destroy]
  match 'destroy_with_bucket_and_item', :to => "bucket_item_pairs#destroy_with_bucket_and_item", :as => "destroy_with_bucket_and_item"

  resources :emails, :only => [:create]

  get 'info', to: 'pages#info', as: 'info'
  
  resources :items, :only => [:create, :update, :destroy, :show, :edit, :new]
  get 'items/:id/assign', to: 'items#assign', as: 'assign_item'

  get 'search', to: 'pages#search', as: 'search'
  
  resources :sms, :only => [:create]

  resources :users, :except => [:index, :new, :create]
  get 'users/:id/items', to: 'users#items'
  get 'users/:id/buckets', to: 'users#buckets', as: 'user_buckets'
  get 'users/:id/reminders', to: 'users#reminders', as: 'user_reminders'

  post 'users/:id/add_to_addon/:addon_id', to: 'users#add_to_addon', as: 'user_add_to_addon'  
  post 'users/:id/remove_from_addon/:addon_id', to: 'users#remove_from_addon', as: 'user_remove_from_addon'
  post "api_endpoint", :to => "addons#api_endpoint", :as => "api_endpoint"

end
