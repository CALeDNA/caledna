# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :researchers, controllers: {
    sessions: 'researchers/sessions',
    invitations: 'researchers/invitations'
  }

  namespace :admin do
    root to: 'samples#index'
    resources :projects
    resources :researchers
    resources :samples
    resources :photos

    controller 'kobo' do
      post 'import_projects'
      post 'import_samples/:id' => 'kobo#import_samples'
      get 'import_kobo'
    end
  end

  resources :samples, only: %i[index show]
  resource :search, only: %i[show]
  resources :projects, only: %i[index show]

  root 'samples#index'
end
