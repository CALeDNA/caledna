# frozen_string_literal: true

class FieldProjectsController < ApplicationController
  include FilterSamples

  def index
    @projects =
      FieldProject
      .published
      .where(where_sql)
      .order(:name)
      .page(params[:page])

    @samples_count = approved_samples_count
    @users_count = User::EXISTING_USERS + User.count + 500
    @events_count = Event.count
  end

  def show
    @project = FieldProject.find(project_id)
  end

  private

  def where_sql
    <<-SQL
    id IN (
      SELECT DISTINCT(field_project_id)
      FROM samples
      WHERE status_cd = 'approved' OR status_cd = 'results_completed'
    )
    SQL
  end

  def project_id
    params[:id]
  end
end
