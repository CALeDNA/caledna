# frozen_string_literal: true

class ProjectsController < ApplicationController
  def index
    @projects = Project.order(:name).page params[:page]
  end

  def show
    @project = Project.find(params[:id])
  end
end
