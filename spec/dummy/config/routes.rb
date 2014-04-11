Rails.application.routes.draw do

  get "house/index"
  mount Exportling::Engine => "/exportling", as: 'export_engine'
end
