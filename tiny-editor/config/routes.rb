Rails.application.routes.draw do
  root "user_sessions#new"

  get "/home", to: "folders#home", :as => :home_path

  get "/docs/new", to: "docs#new"
  post "/docs/save", to: "docs#save"
  get "/docs/:id", to: "docs#get"
  get "/docs/:id/edit", to: "docs#edit"
  post "/docs/:id/save", to: "docs#save"
  post "/docs/:id/destroy", to: "docs#destroy"

  get "/folders/new", to: "folders#new"
  post "/folders/save", to: "folders#save"
  get "/folders/:id", to: "folders#get"
  get "/folders/:id/edit", to: "folders#edit"
  post "/folders/:id/save", to: "folders#save"
  post "/folders/:id/destroy", to: "folders#destroy"

  resources :user_sessions
  resources :users

  get 'login' => 'user_sessions#new', :as => :login
  get 'logout' => 'user_sessions#destroy', :as => :logout
end
