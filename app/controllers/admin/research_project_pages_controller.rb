# frozen_string_literal: true

module Admin
  class ResearchProjectPagesController < Admin::ApplicationController
    layout :resolve_layout

    private

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def scoped_resource
      if current_researcher.superadmin?
        resource_class.default_scoped
      elsif current_researcher.director?
        resource_class.default_scoped
      elsif current_researcher.esie_postdoc?
        resource_class.default_scoped
      else
        resource_class.default_scoped
                      .joins(research_project: :research_project_authors)
                      .where(
                        research_project:
                          { research_project_authors:
                            { authorable_id: current_researcher.id } }
                      )
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end
