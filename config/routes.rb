Hippocampus::Application.routes.draw do
  root :to => "users#show"
  
  resources :buckets, :only => [:create, :update, :destroy]
  
  resources :bucket_item_pairs, :only => [:create, :destroy]

  resources :emails, :only => [:create]
  
  resources :items, :only => [:create, :update, :destroy, :show, :edit, :new]

  resources :sms, :only => [:create]

  resources :users, :only => [:create, :show, :destroy]
  get 'users/:id/items', to: 'users#items'
  get 'users/:id/buckets', to: 'users#buckets'
  
end
