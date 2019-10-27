# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength:
Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  devise_for :researchers, controllers: {
    sessions: 'researchers/sessions',
    invitations: 'researchers/invitations',
    passwords: 'researchers/passwords'
  }

  require 'sidekiq/web'
  authenticate :researcher, ->(u) { u.director? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  namespace :api do
    namespace :v1 do
      resources :taxa, only: %i[index show]
      resources :samples, only: %i[index show]
      resources :research_projects, only: %i[show]
      resources :field_projects, only: %i[show]
      resources :inat_observations, only: %i[index]
      resource :stats do
        get '/home_page', to: 'stats#home_page'
      end
      resource :samples_search, only: %i[show]

      namespace :research_projects do
        namespace :pillar_point do
          params = { slug: 'pillar-point' }
          get 'area_diversity', defaults: params
          get 'common_taxa_map', defaults: params
          get 'biodiversity_bias', defaults: params
          get 'occurrences', defaults: params
          get 'source_comparison_all', defaults: params
          get 'sites', defaults: params
        end

        namespace :la_river do
          params = { slug: 'los-angeles-river' }
          get 'area_diversity', defaults: params
          get 'pa_area_diversity', defaults: params
          get 'sampling_types', defaults: params
          get 'detection_frequency', defaults: params
          get 'sites', defaults: params
        end
      end
    end
  end

  namespace :admin do
    root to: 'labwork/home#index'
    resources :field_projects
    resources :research_projects
    resources :samples
    resources :photos
    resources :extraction_types
    resources :extractions
    resources :asvs
    resources :researchers
    resources :pages
    resources :events
    resources :event_registrations
    resources :site_news
    resources :users
    resources :surveys
    resources :survey_responses
    resources :websites

    get 'events/:id/download_csv', to: 'events#download_csv',
                                   as: 'event_download_csv'

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
        post 'edit_multiple_approvals', as: :edit_multiple_approvals
        put 'update_multiple_approvals'
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
      resources :import_csv_status, only: %i[index]

      resources :normalize_ncbi_taxa, only: %i[index show] do
        put 'update_existing' => 'normalize_ncbi_taxa#update_existing'
        put 'update_create' => 'normalize_ncbi_taxa#update_create'
      end
    end

    controller 'batch_actions' do
      post 'labwork/batch_approve_samples' =>
        'labwork/batch_actions#approve_samples'
      post 'labwork/batch_assign_samples' =>
        'labwork/batch_actions#assign_samples'
      post 'labwork/batch_change_longitude_sign' =>
        'labwork/batch_actions#change_longitude_sign'
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
  resources :field_projects, only: %i[index show]
  resources :taxa, only: %i[index show create]
  resources :events, only: %i[index show] do
    resources :event_registrations, only: %i[create]
    put 'event_registrations_update_status' =>
      'event_registrations#update_status'
  end
  resources :uploads, only: %i[create destroy]
  resource :profile, only: [:show]

  resources :surveys, only: %i[show] do
    resources :survey_responses, only: %i[create show]
  end

  resources :research_projects, only: %i[index show edit] do
    resources :pages, only: %i[show edit update],
                      controller: 'research_projects/pages'
  end

  namespace :beta do
    get 'geojson_demo', to: 'geojson_demo'
    get 'map_v2', to: 'map_v2'
  end

  root 'samples#index'
end
# rubocop:enable Metrics/BlockLength:
