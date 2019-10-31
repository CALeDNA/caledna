# frozen_string_literal: true

module Admin
  class ResearchProjectsController < Admin::ApplicationController
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def create
      authorize_resource(resource)

      if resource.save
        create_user_authors
        create_researcher_authors
        page = create_intro_page(resource)

        redirect_to(
          ['edit', namespace, page],
          notice: translate_with_resource('create.success')
        )
      else
        render :new, locals: {
          page: Administrate::Page::Form.new(dashboard, resource)
        }
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

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

    def create_intro_page(project)
      Page.create(research_project: project,
                  title: 'Introduction',
                  slug: 'intro',
                  menu_text: 'Introduction',
                  body: "Intro for #{project.name}",
                  published: true,
                  display_order: 1,
                  show_map: true,
                  show_edna_results_metadata: true)
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
  end
end
