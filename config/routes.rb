Hippocampus::Application.routes.draw do
  resources :people, :only => [:create, :update, :destroy]
  resources :items, :only => [:create, :update, :destroy, :show]
  resources :users, :only => [:create, :show, :destroy]
end
