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
  authenticate :researcher, ->(u) { u.view_sidekiq? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  namespace :api do
    namespace :v1 do
      resources :primers, only: %i[index]
      resources :taxa, only: %i[index show]
      resources :samples, only: %i[index show]
      resources :research_projects, only: %i[show]
      resources :field_projects, only: %i[show]
      resources :inat_observations, only: %i[index]
      resource :stats, only: [] do
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
          get 'taxonomy_comparison', defaults: params
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
    resources :asvs
    resources :events
    resources :event_registrations
    resources :field_projects
    resources :kobo_photos
    resources :pages
    resources :primers
    resources :research_projects
    resources :researchers
    resources :samples
    resources :site_news
    resources :surveys
    resources :survey_responses
    resources :users
    resources :websites

    get 'events/:id/download_csv', to: 'events#download_csv',
                                   as: 'event_download_csv'
    get 'users_download_csv', to: 'users#download_csv',
                              as: 'users_download_csv'

    namespace :labwork do
      get '/' => 'home#index'

      controller 'kobo' do
        get 'import_kobo'
        post 'import_kobo_projects' => 'kobo#import_projects'
        post 'import_kobo_samples/:id' => 'kobo#import_samples',
             as: :import_kobo_samples
      end

      controller 'approve_samples' do
        get 'approve_samples' => 'approve_samples#index'
        post 'edit_multiple_approvals', as: :edit_multiple_approvals
        put 'update_multiple_approvals'
      end

      resources :import_csv_status, only: %i[index] # Sidekiq dashboard
      resources :import_samples_research_metadata, only: %i[index create]
      resources :import_edna_results_asvs, only: %i[index create]
      resources :import_edna_results_taxa, only: %i[index create]
      resources :import_kobo_field_data, only: %i[index create]

      resources :normalize_ncbi_taxa, only: %i[index show] do
        put 'update_existing' => 'normalize_ncbi_taxa#update_existing'
        put 'update_create' => 'normalize_ncbi_taxa#update_create'
        put 'update_with_id' => 'normalize_ncbi_taxa#update_with_id'
      end

      controller 'taxa_counts' do
        get 'taxa_asvs_count' => 'taxa_counts#taxa_asvs_count'
        put 'update_taxa_asvs_count' => 'taxa_counts#update_taxa_asvs_count'

        get 'la_river_taxa_asvs_count' => 'taxa_counts#la_river_taxa_asvs_count'
        put 'update_la_river_taxa_asvs_count' =>
          'taxa_counts#update_la_river_taxa_asvs_count'
      end
    end

    controller 'batch_actions' do
      post 'labwork/batch_approve_samples' =>
        'labwork/batch_actions#approve_samples'
      post 'labwork/batch_change_longitude_sign' =>
        'labwork/batch_actions#change_longitude_sign'
    end
  end

  resources :samples, only: %i[index show]
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
