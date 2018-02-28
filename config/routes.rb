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

      controller 'process_extractions' do
        get 'process_extractions' => 'process_extractions#index'
        post 'edit_multiple', as: :edit_multiple_extractions
        # post 'edit_multiple', as: :post_edit_multiple_extractions

        # post 'post_edit_multiple', as: :post_edit_multiple_extractions
        # get 'post_edit_multiple', as: :edit_multiple_extractions

        put 'update_multiple'
      end
    end

    controller 'batch_actions' do
      post 'batch_approve_samples' => 'batch_actions#approve_samples'
      post 'batch_reject_samples' => 'batch_actions#reject_samples'
      post 'batch_assign_samples' => 'batch_actions#assign_samples'
      post 'batch_process_extractions' => 'batch_actions#process_extractions'
    end

    resource :reseed_database, only: %i[show]
  end

  resources :samples, only: %i[index show]
  resource :search, only: %i[show]
  resource :taxa_search, only: %i[show]
  resources :field_data_projects, only: %i[index show]
  resources :taxa, only: %i[index show]

  root 'samples#index'
end
# rubocop:enable Metrics/BlockLength:
