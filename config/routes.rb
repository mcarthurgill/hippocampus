Hippocampus::Application.routes.draw do
  resources :items, :only => [:create, :update, :destroy]
  resources :users, :only => [:create, :show, :destroy]
end
