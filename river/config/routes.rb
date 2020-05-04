# frozen_string_literal: true

Rails.application.routes.draw do
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
  get '/our-mission', to: 'river/pages#our_mission', defaults: { id: 'our-mission' }
  get '/our-team', to: 'river/pages#our_team', defaults: { id: 'our-team' }
  get '/why-protect-biodiversity', to: 'river/pages#why_protect_biodiversity',
                                   defaults: { id: 'why-protect-biodiversity' }
  get '/get-involved', to: 'river/pages#get_involved',
                       defaults: { id: 'get-involved' }

  root 'river/pages#home'
end
