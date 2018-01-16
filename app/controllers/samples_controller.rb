class SamplesController < ApplicationController
  def index
    @samples = Sample.order(:bar_code).page params[:page]
  end

  def show
    @sample = Sample.find(params[:id])
  end
end
