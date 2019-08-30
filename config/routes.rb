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
      resources :field_data_projects, only: %i[show]
      resources :inat_observations, only: %i[index]
      resource :stats do
        get '/home_page', to: 'stats#home_page'
      end
      resource :samples_search, only: %i[show]
      get '/pillar_point/area_diversity',
          to: 'research_projects#pillar_point_area_diversity'
      get '/pillar_point/pillar_point_common_taxa_map',
          to: 'research_projects#pillar_point_common_taxa_map'
      get '/pillar_point/pillar_point_biodiversity_bias',
          to: 'research_projects#pillar_point_biodiversity_bias'
      get '/pillar_point/pillar_point_occurrences',
          to: 'research_projects#pillar_point_occurrences'
      get '/pillar_point/source_comparison_all',
          to: 'research_projects#pillar_point_source_comparison_all'
      get '/la_river/area_diversity',
          to: 'la_river#area_diversity'
      get '/la_river/detection_frequency',
          to: 'la_river#detection_frequency'
      get '/la_river/sites',
          to: 'la_river#sites'
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
  resources :field_data_projects, only: %i[index show]
  resources :taxa, only: %i[index show create]
  resources :events, only: %i[index show] do
    resources :event_registrations, only: %i[create]
    put 'event_registrations_update_status' =>
      'event_registrations#update_status'
  end
  resources :uploads, only: %i[create destroy]
  resource :profile, only: [:show]
  resources :pages, only: [:update]

  resources :surveys, only: %i[show] do
    resources :survey_responses, only: %i[create show]
  end

  get 'research_projects/pillar-point', to: 'research_projects#pillar_point',
                                        defaults: { id: 'pillar-point' }

  resources :research_projects, only: %i[index show edit] do
    resources :pages, only: %i[show], controller: 'research_projects',
                      action: 'show_project_page'
  end

  namespace :beta do
    get 'geojson_demo', to: 'geojson_demo'
    get 'map_v2', to: 'map_v2'
  end

  # get '/safety-training-quiz',
  #     to: 'surveys#show',
  #     defaults: { slug: 'safety-training-quiz' }

  # get '/kit-training-quiz',
  #   to: 'surveys#show',
  #   defaults: { slug: 'kit-training-quiz' }

  # home_2 is made of two Page records because there are 2 editable text fields
  get '/home_2', to: 'pages#home_2'

  root 'samples#index'
end
# rubocop:enable Metrics/BlockLength:
