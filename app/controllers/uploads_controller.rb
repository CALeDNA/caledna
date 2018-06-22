# frozen_string_literal: true

class UploadsController < ApplicationController
  def create
    respond_to do |format|
      format.json do
        if new_upload.save
          render json: { id: new_upload.id, url: url_for(new_upload.image) }
        else
          render json: { errors: new_upload.errors.messages }
        end
      end
    end
  end

  def destroy
    upload = Upload.find(params[:id])
    upload.image.purge
    upload.destroy

    respond_to do |format|
      format.json { render json: { status: :ok } }
    end
  end

  private

  def new_upload
    filename = upload_params[:image].original_filename
    @new_upload ||= Upload.new(upload_params.merge(filename: filename))
  end

  def upload_params
    params.require(:upload).permit(:image)
  end
end
