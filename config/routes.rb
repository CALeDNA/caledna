# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength:
Rails.application.routes.draw do
  devise_for :researchers, controllers: {
    sessions: 'researchers/sessions',
    invitations: 'researchers/invitations'
  }

  namespace :admin do
    root to: 'field_data_projects#index'
    resources :field_data_projects
    resources :samples
    resources :extraction_types
    resources :extractions
    resources :photos
    resources :researchers

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
  resources :field_data_projects, only: %i[index show]
  resources :taxa, only: %i[index show]

  root 'samples#index'
end
# rubocop:enable Metrics/BlockLength:
