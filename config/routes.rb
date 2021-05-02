# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength:
Rails.application.routes.draw do
  mount River::Engine, at: '/'

  # require 'sidekiq/web'
  # authenticate :researcher, ->(u) { u.view_sidekiq? } do
  #   mount Sidekiq::Web => '/sidekiq'
  # end

  authenticate :researcher, ->(u) { u.view_pghero? } do
    mount PgHero::Engine, at: 'pghero'
  end

  namespace :api do
    namespace :v1 do
      resources :field_projects, only: %i[show]
      resources :inat_observations, only: %i[index]
      resources :places, only: %i[show] do
        get '/gbif_occurrences', to: 'places#gbif_occurrences'
        get '/kingdom_counts', to: 'places#kingdom_counts'
      end

      resources :primers, only: %i[index]
      resources :research_projects, only: %i[show]
      resources :samples, only: %i[index show] do
        get '/taxa_tree', to: 'samples#taxa_tree'
        get '/taxa_list', to: 'samples#taxa_list'
      end
      get '/basic_samples', to: 'samples#basic_samples'
      resource :samples_search, only: %i[show]
      resource :stats, only: [] do
        get '/home_page', to: 'stats#home_page'
      end
      get '/taxa/next_taxon_id', to: 'taxa#next_taxon_id'
      resources :taxa, only: %i[index show]
      get '/taxa_search', to: 'taxa#taxa_search'

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
          params = { slug: ResearchProject::LA_RIVER_PILOT_SLUG }
          get 'area_diversity', defaults: params
          get 'pa_area_diversity', defaults: params
          get 'sampling_types', defaults: params
          get 'detection_frequency', defaults: params
          get 'sites', defaults: params
        end
      end

      namespace :pour do
        resources :occurrences, only: %i[index]
        get '/inat_occurrences', to: 'occurrences#inat_occurrences'
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength:
