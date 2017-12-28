# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :researchers

    root to: 'researchers#index'
  end

  devise_for :researchers
  root 'application#index'
end
