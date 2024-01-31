Rails.application.routes.draw do
  root "main#index"

  get "/docs/new", to: "docs#new"
  get "/docs/all", to: "docs#all"
  get "/docs/:id", to: "docs#get"
  get "/docs/:id/edit", to: "docs#edit"
  post "/docs/:id/save", to: "docs#save"
end
