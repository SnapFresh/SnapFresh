Allincomefoods::Application.routes.draw do
  #scope "(:locale)", :locale => /en|es/ do
  #  resources :retailers
  #end
  root :to => 'retailers#index'

  match 'browse' => 'retailers#browse'
  match 'retailers/terms', :to=>'retailers#terms'
  #resources :requests
  match 'requests/:address' => 'requests#retailers'
  match 'aboutus' => 'retailers#aboutus'
  get "lookup/new"
  #match 'retailers/near/:lat/:lon' => 'retailers#near',
  #                      :constraints => { :lat => /[-]?[0-9]+\.?[0-9]*/,
  #                                        :lon => /[-]?[0-9]+\.?[0-9]*/ }
  #match 'retailers/list/:address' => 'retailers#list'

  #match 'retailers/nearaddy(.:format)' => 'retailers#nearaddy'
  resources :retailers do
    collection do
      get "nearaddy"
    end
  end

end
