Hippocampus::Application.routes.draw do

  resources :buckets, :only => [:create, :update, :destroy]
  resources :items, :only => [:create, :update, :destroy, :show]
  resources :users, :only => [:create, :show, :destroy]
  
end
