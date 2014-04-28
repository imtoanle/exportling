Rails.application.routes.draw do

  get "house/index"
  mount Exportling::Engine, at: '/exports'
end
