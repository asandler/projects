Rails.application.routes.draw do
  root "main#index"

  get "/docs/:id", to: "docs#get"
  get "/docs/:id/edit", to: "docs#edit"
  post "/docs/:id/save", to: "docs#save"
  post "/docs/new", to: "docs#new"
end
