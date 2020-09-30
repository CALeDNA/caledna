# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength:
Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    confirmations: 'users/confirmations'
  }

  devise_for :researchers, controllers: {
    sessions: 'researchers/sessions',
    invitations: 'researchers/invitations',
    passwords: 'researchers/passwords',
    unlocks: 'researchers/unlocks'
  }

  resources :places, only: %i[index show edit] do
    resources :pages, only: %i[show edit update],
                      controller: 'place_pages'
  end
  resources :samples, only: %i[index show], controller: 'samples'
  resources :taxa, only: %i[index show create], controller: 'taxa'
  resource :taxa_search, only: %i[show]
  resources :site_news, only: %i[index show], controller: 'river/site_news'

  resources :research_projects, only: %i[index show edit],
                                controller: 'research_projects' do
    resources :pages, only: %i[show edit update],
                      controller: 'research_projects/pages'
  end

  resources :pages, only: %i[edit update show], controller: 'river/pages'
  resource :profile, only: [:show]
  resources :events, only: %i[index show] do
    resources :event_registrations, only: %i[create]
    put 'event_registrations_update_status' =>
      'event_registrations#update_status'
  end
  resources :river_stories, only: %i[index show new create],
                            controller: :user_submissions
  resource :river_explorer, only: %i[show], controller: 'river/river_explorers'


  get '/faq', to: 'river/pages#show', defaults: { id: 'faq' }
  get '/our-mission', to: 'river/pages#show', defaults: { id: 'our-mission' }
  get '/our-team', to: 'river/pages#show', defaults: { id: 'our-team' }
  get '/why-protect-biodiversity', to: 'river/pages#show',
                                   defaults: { id: 'why-protect-biodiversity' }
  get '/get-involved', to: 'river/pages#show',  defaults: { id: 'get-involved' }
  get '/donate', to: 'river/pages#show', defaults: { id: 'donate' }
  get '/beta', to: 'river/pages#show', defaults: { id: 'beta' }
  get '/disclaimer', to: 'river/pages#show', defaults: { id: 'disclaimer' }
  get '/samples-analyzed', to: 'river/pages#show', defaults: { id: 'samples-analyzed' }

  get '/contact-us', to: 'river/contacts#new'
  resources :contacts, only: [:create], controller: 'river/contacts'

  # used when uploading images via the text editor
  resources :uploads, only: %i[create destroy]

  root 'river/pages#home'

  namespace :admin do
    root to: 'pages#index'
    resources :pages
    resources :page_blocks
    resources :places
    resources :place_pages
    resources :user_submissions
    resources :site_news
    resources :websites
  end
end
# rubocop:enable Metrics/BlockLength:
