Exportling::Engine.routes.draw do
  # TODO: Consider allowing #new to accept POST requests
  #       Params supplied to #new may exceed GET length limits
  resources :exports do
    member do
      get :download
      get :retry
    end
  end

  root to: 'exports#index'
end
