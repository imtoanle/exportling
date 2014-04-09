Exportling::Engine.routes.draw do
  resources :exports do
    get :download
  end

  root to: 'exports#index'
end

Rails.application.routes.draw do
  get "/exportling/export/:owner_id/:export_id/:basename.:extension", :controller => "exportling/exports", :action => 'download'
end
