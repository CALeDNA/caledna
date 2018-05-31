# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength:
Rails.application.routes.draw do
  devise_for :researchers, controllers: {
    sessions: 'researchers/sessions',
    invitations: 'researchers/invitations'
  }

  namespace :api do
    namespace :v1 do
      resources :taxa, only: [:index]
    end
  end

  namespace :admin do
    root to: 'labwork/home#index'
    resources :field_data_projects
    resources :research_projects
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
        post 'import_kobo_projects' => 'kobo#import_projects'
        post 'import_kobo_samples/:id' => 'kobo#import_samples',
             as: :import_kobo_samples
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
        put 'update_multiple'
      end

      resources :import_samples, only: %i[index create]
      resources :import_results_asvs, only: %i[index create]
      resources :import_results_taxa, only: %i[index create]
      resources :import_processing_extractions, only: %i[index create]

      # resources :normalize_gbif_taxa, only: %i[index show] do
      #   put 'update_existing' => 'normalize_gbif_taxa#update_existing'
      #   put 'update_create' => 'normalize_gbif_taxa#update_create'
      #   post 'duplicate' => 'normalize_gbif_taxa#duplicate'
      # end

      resources :normalize_ncbi_taxa, only: %i[index show] do
        put 'update_existing' => 'normalize_ncbi_taxa#update_existing'
        put 'update_create' => 'normalize_ncbi_taxa#update_create'
      end
    end

    controller 'batch_actions' do
      post 'labwork/batch_approve_samples' =>
        'labwork/batch_actions#approve_samples'
      post 'labwork/batch_reject_samples' =>
        'labwork/batch_actions#reject_samples'
      post 'labwork/batch_duplicate_barcode_samples' =>
        'labwork/batch_actions#duplicate_barcode_samples'
      post 'labwork/batch_assign_samples' =>
        'labwork/batch_actions#assign_samples'
      post 'labwork/batch_process_extractions' =>
        'labwork/batch_actions#process_extractions'
    end

    controller 'reset_database' do
      get 'delete_fieldwork_data' =>
        'labwork/reset_database#delete_fieldwork_data'
      get 'delete_labwork_data' => 'labwork/reset_database#delete_labwork_data'
    end
  end

  resources :samples, only: %i[index show]
  resource :search, only: %i[show]
  resource :taxa_search, only: %i[show]
  resources :field_data_projects, only: %i[index show]
  resources :taxa, only: %i[index show create]
  resources :research_projects, only: %i[index show]

  root 'samples#index'
end
# rubocop:enable Metrics/BlockLength:
