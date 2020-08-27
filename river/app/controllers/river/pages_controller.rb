# frozen_string_literal: true

module River
  class PagesController < ApplicationController
    layout 'river/application'

    def edit
      redirect_to research_projects_path unless current_researcher

      @page = page
    end

    def update
      if current_researcher && page.update(raw_params)
        redirect_to "/#{params[:id]}"

      else
        flash[:error] = 'Something went wrong. Changes not saved'
        redirect_to request.referrer
      end
    end

    def show
      @page = page
    end

    # rubocop:disable Metrics/AbcSize
    def home
      @stats = project_service.home_page_stats
      @block_1 = home_blocks.find { |b| b.slug == 'pour-home-1' }
      @block_2 = home_blocks.find { |b| b.slug == 'pour-home-2' }
      @block_3 = home_blocks.find { |b| b.slug == 'pour-home-3' }
      @block_donate = home_blocks.find { |b| b.slug == 'pour-home-donate' }
      @news = home_news
      render layout: 'river/home'
    end
    # rubocop:enable Metrics/AbcSize

    def why_protect_biodiversity
      @page = page
      render 'river/pages/show'
    end

    def donate
      @page = page
      render 'river/pages/show'
    end

    private

    def home_news
      @home_news ||=
        SiteNews.current_site.published.order('published_date DESC').limit(3)
    end

    def home_blocks
      @home_blocks ||= Page.find_by(slug: 'pour-home-page').page_blocks
    end

    def page
      @page ||= Page.current_site.published.find_by(slug: params[:id])
    end

    def project
      @project ||= ResearchProject.find_by(slug: 'los-angeles-river')
    end

    def project_service
      @project_service ||= begin
        ResearchProjectService::LaRiver.new(project, params)
      end
    end

    def raw_params
      params.require(:page)
            .permit(:body, :title)
    end
  end
end
