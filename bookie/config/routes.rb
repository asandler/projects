Rails.application.routes.draw do
#  root :to => 'users#index'
  resources :user_sessions
  resources :users

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout

  get 'welcome/index'

  post 'books/new' => 'books#create'
  get 'books/:book_id/pages/:page_number' => 'pages#show', as: :show_page
  get 'books/:book_id/read' => 'books#read', as: :read_book
  get 'read_json' => 'books#read_json', as: :read_json
  get 'read_json_contents' => 'books#read_json_contents', as: :read_json_contents
  get 'save_bookmark' => 'books#save_bookmark', as: :save_bookmark
  post 'save_paragraph' => 'books#save_paragraph', as: :save_paragraph
  post 'books/:book_id/edit' => 'books#update', as: :update_book

  get 'books/:book_id/pages/:page_number/edit' => 'pages#edit_get', as: :edit_page_get
  post 'books/:book_id/pages/:page_number/edit' => 'pages#edit_post', as: :edit_page_post

  get 'my_books' => 'books#personal_index', as: :personal_index
  get 'my_books/add' => 'books#add_to_personal', as: :add_book
  delete 'my_books/:book_id' => 'books#destroy_personal', as: :destroy_personal

  resources :books do
    resources :pages
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
