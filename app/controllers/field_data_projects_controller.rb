# frozen_string_literal: true

class FieldDataProjectsController < ApplicationController
  def index
    @projects = FieldDataProject.order(:name).page params[:page]
  end

  def show
    @project = FieldDataProject.find(params[:id])
  end
end
