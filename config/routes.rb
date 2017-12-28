# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :researchers, controllers: {
    sessions: 'researchers/sessions',
    invitations: 'researchers/invitations'
  }

  namespace :admin do
    resources :researchers

    root to: 'researchers#index'
  end

  root 'application#index'
end
