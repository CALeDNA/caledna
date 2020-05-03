# frozen_string_literal: true

Rails.application.routes.draw do
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
