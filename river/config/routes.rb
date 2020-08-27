# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength:
Rails.application.routes.draw do
  devise_for :researchers, controllers: {
    sessions: 'researchers/sessions',
    invitations: 'researchers/invitations',
    passwords: 'researchers/passwords',
    unlocks: 'researchers/unlocks'
  }

  resources :samples, only: %i[index show], controller: 'samples'
  resources :taxa, only: %i[index show create], controller: 'taxa'
  resource :taxa_search, only: %i[show]
  resources :site_news, only: %i[index show], controller: 'river/site_news'

  resources :research_projects, only: %i[index show edit],
                                controller: 'research_projects' do
    resources :pages, only: %i[show edit update],
                      controller: 'research_projects/pages'
  end

  resources :pages, only: %i[edit update], controller: 'river/pages'

  get '/faq', to: 'river/pages#faq', defaults: { id: 'faq' }
  get '/our-mission', to: 'river/pages#our_mission',
                      defaults: { id: 'our-mission' }
  get '/our-team', to: 'river/pages#our_team', defaults: { id: 'our-team' }
  get '/why-protect-biodiversity', to: 'river/pages#why_protect_biodiversity',
                                   defaults: { id: 'why-protect-biodiversity' }
  get '/get-involved', to: 'river/pages#get_involved',
                       defaults: { id: 'get-involved' }
  get '/donate', to: 'river/pages#donate', defaults: { id: 'donate' }

  get '/contact-us', to: 'river/contacts#new'
  resources :contacts, only: [:create], controller: 'river/contacts'

  root 'river/pages#home'

  namespace :admin do
    root to: 'pages#index'
    resources :pages
    resources :page_blocks
    resources :site_news
    resources :websites
  end
end
# rubocop:enable Metrics/BlockLength:
