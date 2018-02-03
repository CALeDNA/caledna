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

    controller 'assign_samples' do
      get 'assign_samples' => 'assign_samples#index'
    end

    controller 'approve_samples' do
      get 'approve_samples' => 'approve_samples#index'
    end

    controller 'batch_actions' do
      post 'batch_approve_samples' => 'batch_actions#approve_samples'
      post 'batch_reject_samples' => 'batch_actions#reject_samples'
      post 'batch_assign_samples' => 'batch_actions#assign_samples'
    end
  end

  resources :samples, only: %i[index show]
  resource :search, only: %i[show]
  resources :projects, only: %i[index show]

  root 'samples#index'
end
