# frozen_string_literal: true

class FieldProjectsController < ApplicationController
  def index
    @projects =
      FieldProject
      .published
      .where('id IN (SELECT DISTINCT(field_project_id) from samples)')
      .order(:name)
      .page(params[:page])
  end

  def show
    @project = FieldProject.find(project_id)
  end

  private

  def project_id
    params[:id]
  end
end
