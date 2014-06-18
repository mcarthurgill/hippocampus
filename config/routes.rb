Hippocampus::Application.routes.draw do
  resources :people, :only => [:create, :update, :destroy]
  resources :items, :only => [:create, :update, :destroy]
  resources :users, :only => [:create, :show, :destroy]
end
