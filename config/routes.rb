# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :researchers, controllers: {
    sessions: 'researchers/sessions',
    invitations: 'researchers/invitations'
  }

  namespace :admin do
    root to: 'projects#index'
    resources :projects
    resources :samples
    resources :researchers

    controller 'kobo' do
      post 'import_projects'
      post 'import_samples/:id' => 'kobo#import_samples'
      get 'import_kobo'
    end
  end

  resources :samples, only: %i[index show]
  resource :map, only: %i[show]
  resource :search, only: %i[show]
  resources :projects, only: %i[index show]

  root 'maps#show'
end
