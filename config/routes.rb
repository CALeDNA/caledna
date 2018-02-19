# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength:
Rails.application.routes.draw do
  devise_for :researchers, controllers: {
    sessions: 'researchers/sessions',
    invitations: 'researchers/invitations'
  }

  namespace :admin do
    root to: 'labwork/home#index'
    resources :field_data_projects
    resources :samples
    resources :photos
    resources :extraction_types
    resources :extractions
    resources :asvs
    resources :researchers

    namespace :labwork do
      get '/' => 'home#index'

      controller 'kobo' do
        get 'import_kobo'
        post 'import_projects' => 'kobo#import_projects'
        post 'import_samples/:id' => 'kobo#import_samples', as: :import_samples
      end

      controller 'assign_samples' do
        get 'assign_samples' => 'assign_samples#index'
      end

      controller 'approve_samples' do
        get 'approve_samples' => 'approve_samples#index'
      end
    end

    controller 'batch_actions' do
      post 'batch_approve_samples' => 'batch_actions#approve_samples'
      post 'batch_reject_samples' => 'batch_actions#reject_samples'
      post 'batch_assign_samples' => 'batch_actions#assign_samples'
    end
  end

  resources :samples, only: %i[index show]
  resource :search, only: %i[show]
  resource :taxa_search, only: %i[show]
  resources :field_data_projects, only: %i[index show]
  resources :taxa, only: %i[index show]

  root 'samples#index'
end
# rubocop:enable Metrics/BlockLength:
