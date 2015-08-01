Rails.application.routes.draw do
  root :to => 'pages#home'

  get 'about' => 'pages#about'
  get 'terms' => 'pages#terms'

  # To be depreciated
  resources :retailers do
    collection do
      get "nearaddy"
    end
  end

end
