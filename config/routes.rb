Hippocampus::Application.routes.draw do

  resources :calls
  post 'transcribe', :to => 'calls#transcribe'


  root :to => "outside#splash"

  get "login", :to => "sessions#new", :as => "login"
  post 'session/:phone', :to => "sessions#create", :as => "create_session"
  post 'session', :to => "sessions#create"
  post 'session_token', :to => "sessions#create_with_token"
  get 'logout', :to => "sessions#destroy", :as => "logout"
  match 'passcode', :to => "sessions#passcode", :as => "passcode"
  
  match 'next', :to => "introductions#next", :as => "next"
  match 'fail', :to => "introductions#fail", :as => "fail"
  match 'intro_questions', :to => "introductions#get_questions", :as => "get_intro_questions"

  get 'buckets/changes', :to => 'buckets#changes', :as => "buckets_changes"
  put 'buckets/change_group_for_user', :to => 'buckets#change_group_for_user', :as => "change_group_for_user"
  resources :buckets, :only => [:show, :new, :edit, :create, :update, :destroy]
  get 'buckets/:id/media_urls', :to => 'buckets#media_urls', :as => "bucket_media_urls"
  get 'buckets/:id/info', :to => 'buckets#info', :as => "bucket_info"
  get 'buckets/:id/detail', :to => 'buckets#detail', :as => "bucket_detail"
  post 'buckets/:id/add_collaborators', :to => 'buckets#add_collaborators', :as => "bucket_add_collaborators"
  post 'buckets/:id/remove_collaborators', :to => 'buckets#remove_collaborators', :as => "bucket_remove_collaborators"
  
  resources :bucket_item_pairs, :only => [:create, :destroy]
  match 'destroy_with_bucket_and_item', :to => "bucket_item_pairs#destroy_with_bucket_and_item", :as => "destroy_with_bucket_and_item"

  resources :contact_cards, :only => [:create, :destroy]

  resources :device_tokens, :only => [:create]

  resources :emails, :only => [:create]

  resources :groups, only: [:create, :update, :destroy]

  resource :inbox, :controller => 'inbox', :only => [:show, :create]

  get 'info', to: 'pages#info', as: 'info'
  
  get 'items/changes', :to => 'items#changes', :as => "items_changes"
  get 'items/random', to: 'items#random_items', as: 'random_items'
  get 'items/near_location', to: 'items#near_location', as: 'items_near_location'
  get 'items/within_bounds', to: 'items#within_bounds', as: 'items_within_bounds'
  resources :items, :only => [:create, :update, :destroy, :show, :edit, :new, :index]
  get 'items/:id/assign', to: 'items#assign', as: 'assign_item'

  get 'search', to: 'pages#search', as: 'search'
  
  resources :sms, :only => [:create]

  get 'setup_questions', to: 'setup_questions#get_questions', as: 'setup_questions'
  post 'create_from_setup_questions', to: 'setup_questions#create_from_question', as: 'create_from_question'

  resources :users, :except => [:index, :new, :create, :destroy]
  get 'users/:id/items', to: 'users#items'
  get 'users/:id/buckets', to: 'users#buckets', as: 'user_buckets'
  get 'users/:id/grouped_buckets', to: 'users#grouped_buckets', as: 'user_grouped_buckets'
  get 'users/:id/reminders', to: 'users#reminders', as: 'user_reminders'

  post 'users/:id/add_to_addon/:addon_id', to: 'users#add_to_addon', as: 'user_add_to_addon'  
  post 'users/:id/remove_from_addon/:addon_id', to: 'users#remove_from_addon', as: 'user_remove_from_addon'
  post "api_endpoint", :to => "addons#api_endpoint", :as => "api_endpoint"

  resources :use_cases

end
