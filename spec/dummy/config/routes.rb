require 'sidekiq/web'

Rails.application.routes.draw do

  get "house/index"
  mount Sidekiq::Web => '/sidekiq'
  mount Exportling::Engine, at: '/exports'
end
