# frozen_string_literal: true

module Admin
  class ReseedDatabasesController < Admin::ApplicationController
    def show
      raise ReseedNotAllowedError if Rails.env.production?
      raise ReseedNotAllowedError unless current_researcher.director?

      Rails.application.load_seed
      flash[:success] = 'Staging data is reset'
      redirect_to admin_root_path
    end
  end
end

class ReseedNotAllowedError < StandardError; end
