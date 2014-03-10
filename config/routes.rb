Exportling::Engine.routes.draw do
  resources :exports do
    get :download
  end
end
