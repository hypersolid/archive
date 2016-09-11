Quizmaster::Application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks", :registrations => "registrations" }

  resources :users

  # Directs /admin/products/* to Admin::ProductsController
  # (app/controllers/admin/products_controller.rb)
  namespace :admin do
    resources :questions
    resources :tournaments
    resources :users do
      member do
        post :add_credit
        get :passes
      end
    end

    match '/' => "tournaments#index"

    resources :reports do
      collection do
        get 'answers'
      end
    end
  end

  resource :quiz do
    collection do
      get 'quiz'
      get 'answer'
      get 'game_over'
      get 'paystatus'
      get 'wait'
      get 'error'
      get 'bootstrap'
    end
  end

  resources :ladders do
    collection do
      get 'list_ladders'
      get 'fetch_ladders'
      get 'wingmen_panel'
      get 'remove_wingman'
      get 'game_over'
      post 'nudge_wingman'
      post 'pay_wingman'
    end

    member do
      get 'overlay'
    end
  end

  resources :payments do
    collection do
      get 'callback'
      post 'callback'
      get 'incomplete'
    end
  end

  resources :wall_messages do
    collection do
      get 'more'
    end
  end

  resources :email_invites
  # resources :facebook_invites
  resources :email_fallbacks

  match '/pages/:name' => "pages#index"

  root :to => "ladders#index"

end
