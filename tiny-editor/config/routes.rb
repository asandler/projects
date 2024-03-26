Rails.application.routes.draw do
  root "user_sessions#new"

  get "/docs/all", to: "docs#all", :as => :docs_path
  get "/docs/new", to: "docs#new"
  post "/docs/save", to: "docs#save"

  get "/docs/:id", to: "docs#get"
  get "/docs/:id/edit", to: "docs#edit"
  post "/docs/:id/save", to: "docs#save"
  post "/docs/:id/delete", to: "docs#delete"

  resources :user_sessions
  resources :users

  #get 'login' => 'user_sessions#new', :as => :login
  #post 'logout' => 'user_sessions#destroy', :as => :logout
end
