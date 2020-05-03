# frozen_string_literal: true

module River
  class PagesController < ApplicationController
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

    def our_mission
      @page = page
      render 'river/pages/show'
    end

    def our_team
      @page = page
      render 'river/pages/show'
    end

    def faq
      @page = page
      render 'river/pages/show'
    end

    # rubocop:disable Naming/AccessorMethodName
    def get_involved
      @page = page
      render 'river/pages/show'
    end
    # rubocop:enable Naming/AccessorMethodName

    def home
      @stats = project_service.home_page_stats
      render layout: 'river/home'
    end

    def why_protect_biodiversity
      @page = page
      render 'river/pages/show'
    end

    private

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
