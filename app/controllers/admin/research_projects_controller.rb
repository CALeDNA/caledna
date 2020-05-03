# frozen_string_literal: true

module Admin
  class ResearchProjectsController < Admin::ApplicationController
    layout :resolve_layout

    def edna_results
      @project = ResearchProject.find(params[:research_project_id])
      @samples = edna_results_samples
      @primers = edna_results_primers
    end

    # rubocop:disable Metrics/MethodLength
    def create
      authorize_resource(resource)

      if resource.save
        create_user_authors
        create_researcher_authors

        redirect_to(
          [namespace, resource],
          notice: translate_with_resource('create.success')
        )
      else
        render :new, locals: {
          page: Administrate::Page::Form.new(dashboard, resource)
        }
      end
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    def update
      if requested_resource.update(resource_params)
        update_user_authors
        update_researcher_authors

        redirect_to(
          [namespace, requested_resource],
          notice: translate_with_resource('update.success')
        )
      else
        render :edit, locals: {
          page: Administrate::Page::Form.new(dashboard, requested_resource)
        }
      end
    end
    # rubocop:enable Metrics/MethodLength

    private

    def edna_results_primers
      @edna_results_primers ||= begin
        Asv.select('primers.name', 'count(distinct(asvs.taxon_id)) as count')
           .joins('JOIN primers on asvs.primer_id = primers.id')
           .where('asvs.research_project_id = ?', params[:research_project_id])
           .order('primers.name')
           .group('primers.name')
      end
    end

    # rubocop:disable Metrics/MethodLength
    def edna_results_samples
      @edna_results_samples ||= begin
        id = params[:research_project_id]
        Sample
          .select('count(asvs.id) as count', 'samples.barcode')
          .select('latitude', 'longitude', 'samples.id')
          .select('research_project_sources.metadata')
          .joins(:asvs)
          .where('asvs.research_project_id = ?', id)
          .group('samples.barcode', 'latitude', 'longitude', 'samples.id',
                 'research_project_sources.metadata')
          .order('barcode')
          .joins('LEFT JOIN research_project_sources ' \
                 'ON samples.id = research_project_sources.sourceable_id ' \
                 "AND research_project_sources.sourceable_type = 'Sample' " \
                 'AND research_project_sources.research_project_id = ', id)
      end
      # rubocop:enable Metrics/MethodLength
    end

    def resource
      @resource ||= resource_class.new(resource_params)
    end

    def create_user_authors
      create_authors(user_ids, 'User')
    end

    def create_researcher_authors
      create_authors(researcher_ids, 'Researcher')
    end

    def create_authors(ids, type)
      ids.each do |id|
        ResearchProjectAuthor.create(authorable_id: id,
                                     research_project_id: resource.id,
                                     authorable_type: type)
      end
    end

    def update_user_authors
      new_ids = user_ids - current_user_ids(requested_resource)
      deleted_ids = current_user_ids(requested_resource) - user_ids

      create_delete_authors(new_ids, deleted_ids, 'User')
    end

    def update_researcher_authors
      new_ids = researcher_ids - current_researcher_ids(requested_resource)
      deleted_ids = current_researcher_ids(requested_resource) - researcher_ids

      create_delete_authors(new_ids, deleted_ids, 'Researcher')
    end

    def create_delete_authors(new_ids, deleted_ids, type)
      new_ids.each do |id|
        ResearchProjectAuthor.create(authorable_id: id,
                                     research_project_id: requested_resource.id,
                                     authorable_type: type)
      end

      ResearchProjectAuthor.delete(authorable_id: deleted_ids,
                                   research_project_id: requested_resource.id,
                                   authorable_type: type)
    end

    def user_ids
      params[:research_project][:user_authors]
        .reject(&:empty?).map(&:to_i)
    end

    def researcher_ids
      params[:research_project][:researcher_authors]
        .reject(&:empty?).map(&:to_i)
    end

    def current_user_ids(target_resource)
      @current_user_ids ||= begin
        ResearchProjectAuthor
          .where(authorable_type: 'User')
          .where(research_project_id: target_resource.id)
          .pluck(:authorable_id)
      end
    end

    def current_researcher_ids(target_resource)
      @current_researcher_ids ||= begin
        ResearchProjectAuthor
          .where(authorable_type: 'Researcher')
          .where(research_project_id: target_resource.id)
          .pluck(:authorable_id)
      end
    end

    def resource_params
      clean_array_params
      super
    end

    def clean_array_params
      # NOTE: selectize multi adds '' to the array of values.
      ResearchProjectDashboard::ARRAY_FIELDS.each do |f|
        next if params[:research_project][f].blank?
        params[:research_project][f] =
          params[:research_project][f].reject(&:blank?)
      end
    end
  end
end
