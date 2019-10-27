# frozen_string_literal: true

class FieldProjectsController < ApplicationController
  include PaginatedSamples
  include BatchData

  def index
    @projects =
      FieldProject
      .published
      .where('id IN (SELECT DISTINCT(field_project_id) from samples)')
      .order(:name)
      .page(params[:page])
  end

  def show
    @samples = samples
    @project = FieldProject.find(project_id)
    @asvs_count = counts
  end

  private

  def counts
    @counts ||= list_view? ? asvs_count : []
  end

  def samples
    @samples ||= list_view? ? field_project_paginated_samples : []
  end

  def project_id
    params[:id]
  end
end
