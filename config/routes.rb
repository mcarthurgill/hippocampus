Hippocampus::Application.routes.draw do

  root to: "pages#splash"

  resources :buckets, :only => [:create, :update, :destroy]
  
  resources :bucket_item_pairs, :only => [:create, :destroy]

  resources :emails, :only => [:create]
  
  resources :items, :only => [:create, :update, :destroy, :show]

  get 'search', to: 'pages#search', as: 'search'
  
  resources :sms, :only => [:create]

  resources :users, :only => [:create, :show, :edit, :update, :destroy]
  get 'users/:id/items', to: 'users#items'
  get 'users/:id/buckets', to: 'users#buckets'
  
end
