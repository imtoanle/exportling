Exportling::Engine.routes.draw do
  resources :exports do
    member do
      get :download
    end
  end

  root to: 'exports#index'
end
