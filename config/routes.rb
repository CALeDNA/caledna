# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :researchers, controllers: {
    sessions: 'researchers/sessions',
    invitations: 'researchers/invitations'
  }

  namespace :admin do
    root to: 'researchers#index'
    resources :researchers
    controller 'kobo' do
      get 'list_projects'
    end
  end

  root 'application#index'
end
