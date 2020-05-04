# frozen_string_literal: true

module River
  class SiteNewsController < ApplicationController
    def index
      @news = SiteNews.current_site.published
    end

    def show
      @news = SiteNews.current_site.published.find(params[:id])
    end
  end
end
