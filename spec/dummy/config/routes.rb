Rails.application.routes.draw do

  get "house/index"
  get "house/export"
  mount Exportling::Engine => "/exportling", as: 'export_engine'
end
