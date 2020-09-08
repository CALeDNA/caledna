# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength:
Rails.application.routes.draw do
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

  get '/faq', to: 'river/pages#show', defaults: { id: 'faq' }
  get '/our-mission', to: 'river/pages#show', defaults: { id: 'our-mission' }
  get '/our-team', to: 'river/pages#show', defaults: { id: 'our-team' }
  get '/why-protect-biodiversity', to: 'river/pages#show',
                                   defaults: { id: 'why-protect-biodiversity' }
  get '/get-involved', to: 'river/pages#show',  defaults: { id: 'get-involved' }
  get '/donate', to: 'river/pages#show', defaults: { id: 'donate' }
  get '/beta', to: 'river/pages#show', defaults: { id: 'beta' }

  get '/contact-us', to: 'river/contacts#new'
  resources :contacts, only: [:create], controller: 'river/contacts'

  root 'river/pages#home'

  namespace :admin do
    root to: 'pages#index'
    resources :pages
    resources :page_blocks
    resources :places
    resources :place_pages
    resources :site_news
    resources :websites
  end
end
# rubocop:enable Metrics/BlockLength:
