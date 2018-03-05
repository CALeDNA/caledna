# frozen_string_literal: true

module Admin
  class ReseedDatabaseController < Admin::ApplicationController
    def delete_data
      raise ReseedNotAllowedError if Rails.env.production?
      raise ReseedNotAllowedError unless current_researcher.director?

      models = [Highlight, Asv, Photo, Extraction, Extraction,
                ExtractionType, Sample, FieldDataProject]
      models.each(&:destroy_all)

      flash[:success] = 'Staging data deleted'
      redirect_to admin_root_path
    end

    def delete_and_seed_data
      raise ReseedNotAllowedError if Rails.env.production?
      raise ReseedNotAllowedError unless current_researcher.director?

      Rails.application.load_seed
      flash[:success] = 'Staging data deleted and demo project created'
      redirect_to admin_root_path
    end
  end
end

class ReseedNotAllowedError < StandardError
end
