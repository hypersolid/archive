Coolometer::Application.routes.draw do
  devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout'}

  root :to => "fights#show"

  match 'admin' => 'main#admin'
  namespace :admin do
    resources :fights 
    resources :votes
    resources :brands
    resources :suggestions
  end

  resources :votes do
    collection do
      post 'label'
      get  'labels'
    end
  end  
 
  resources :suggestions
  match '/sitemap' => 'sitemaps#sitemap'
  
  match "/:id" => "fights#show"
  match "/:id/:brand_id" => "fights#show"
  resources :fights do
    member do
      get 'gstatus'
    end
  end
end