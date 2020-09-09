# frozen_string_literal: true

class UserSubmissionsController < ApplicationController
  def index
    @submissions = UserSubmission.approved.order(created_at: :desc).page(params[:page])
  end

  def show
    @submission = UserSubmission.approved.find(params[:id])
  end
end
