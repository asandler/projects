Rails.application.routes.draw do
  root "docs#all"

  get "/docs/new", to: "docs#new"
  get "/docs/:id", to: "docs#get"
  get "/docs/:id/edit", to: "docs#edit"
  post "/docs/:id/save", to: "docs#save"
end
