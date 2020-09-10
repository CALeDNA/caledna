# frozen_string_literal: true

class UserSubmissionsController < ApplicationController
  def index
    @submissions = UserSubmission.approved.order(created_at: :desc)
                                 .page(params[:page])
  end

  def show
    @submission = UserSubmission.approved.find(params[:id])
  end

  def new
    @submission = UserSubmission.new
  end

  def create
    @submission = UserSubmission.new(create_params)

    if @submission.save
      flash[:success] = 'Thank you for your submission! We will email you ' \
        'once we review your submission.'
      redirect_to new_user_submission_path
    else
      flash[:failure] = 'There are errors with your submission.'
      render :new
    end
  end

  private

  # rubocop:disable Metrics/MethodLength
  def create_params
    params.require(:user_submission).permit(
      :user_display_name,
      :title,
      :user_bio,
      :content,
      :media_url,
      :twitter,
      :facebook,
      :instagram,
      :website,
      :image
    ).merge(user: current_user)
  end
  # rubocop:enable Metrics/MethodLength
end
