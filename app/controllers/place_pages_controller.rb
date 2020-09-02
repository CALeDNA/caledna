# frozen_string_literal: true

class PlacePagesController < ApplicationController
  layout 'river/application' if CheckWebsite.pour_site?

  def show
    @place = Place.find(params[:place_id])
    @page = PlacePage.find_by(place_id: params[:place_id], slug: params[:id])
  end
end
