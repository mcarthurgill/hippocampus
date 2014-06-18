Hippocampus::Application.routes.draw do
  resources :users, :only => [:create, :show, :destroy]
end
