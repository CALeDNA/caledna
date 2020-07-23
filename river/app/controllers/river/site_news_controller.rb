# frozen_string_literal: true

module River
  class SiteNewsController < ApplicationController
    layout 'river/application'

    def index
      @news = SiteNews.current_site.published.order('published_date DESC')
    end

    def show
      @news = SiteNews.current_site.published.find(params[:id])
    end
  end
end
