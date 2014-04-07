Exportling::Engine.routes.draw do
  resources :exports do
    get :download
  end

  root to: 'exports#index'
end
