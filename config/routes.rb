Allincomefoods::Application.routes.draw do
  root :to => 'retailers#index'

  get 'about' => 'pages#about'
  get 'terms' => 'pages#terms'

  resources :retailers do
    collection do
      get "nearaddy"
    end
  end

end
