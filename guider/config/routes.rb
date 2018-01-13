Rails.application.routes.draw do
  get 'oauths/oauth'

  post "oauth/callback" => "oauths#callback"
  get "oauth/callback" => "oauths#callback" # for use with Facebook
  get "oauth/:provider" => "oauths#oauth", :as => :auth_at_provider

  resources :user_sessions
  resources :users
  resources :password_resets

  post 'search' => 'main#search'
  get 'search' => 'main#search'
  get 'logout' => 'user_sessions#destroy', :as => :logout

  get 'users/:user_id/profile' => 'users#profile', :as => :profile
  get 'users/:user_id/edit_profile' => 'users#edit', :as => :edit_profile
  post 'users/:user_id/edit_profile' => 'users#update_profile'

  get 'users/:user_id/routes' => 'routes#index', :as => :routes
  get 'users/:user_id/new_route' => 'routes#new', :as => :new_route
  post 'users/:user_id/routes' => 'routes#create', :as => :create_route
  get 'users/:user_id/update_route/:route_id' => 'routes#update_route', :as => :update_route
  post 'users/:user_id/update_route/:route_id' => 'routes#update', :as => :update_route_post
  post 'users/:user_id/delete_route/:route_id' => 'routes#destroy', :as => :delete_route

  get 'users/:user_id/bookings' => 'bookings#index', :as => :personal_booking
  post 'users/:user_id/bookings' => 'bookings#new_message', :as => :new_message

  get 'users/:user_id/replies' => 'users#reply', :as => :reply
  post 'users/:user_id/replies' => 'users#add_reply'

  get 'routes/:route_id/book' => 'routes#book', :as => :book_route
  post 'routes/:route_id/book' => 'bookings#new', :as => :new_booking

  post 'bookings/:booking_id/delete' => 'bookings#destroy', :as => :delete_booking

  get 'users/:user_id/requests' => 'requests#index', :as => :personal_requests

  get 'api/cities' => 'api#cities', :as => :api_cities
  get 'api/user_info/:id' => 'api#user_info', :as => :api_user_info
  get 'api/user_routes/:id' => 'api#user_routes', :as => :api_user_routes
  get 'api/user_avatar/:id' => 'api#user_avatar', :as => :api_user_avatar
  get 'api/route_info/:id' => 'api#route_info', :as => :api_route_info
  get 'api/route_image' => 'api#route_image', :as => :api_route_image
 
  post '/' => 'main#find'
  root 'main#find'
end
