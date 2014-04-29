require 'sidekiq/web'

Rails.application.routes.draw do

  get "house/index"
  mount Exportling::Engine, at: '/exports'
  mount Sidekiq::Web => '/sidekiq'
end
