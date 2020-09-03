# frozen_string_literal: true

class PlacesController < ApplicationController
  layout 'river/application' if CheckWebsite.pour_site?

  def index
    @places = places
  end

  def show
    redirect_show if place&.show_pages?
    @place = place
  end

  private

  def places
    @places ||= begin
      if CheckWebsite.caledna_site?
        all_places.where('place_type_cd IN (?)', ['UCNRS'])
      else
        all_places.where('place_type_cd IN (?)', ['pour_location'])
      end
    end
  end

  def all_places
    @all_places ||= begin
      Place
        .select('id', 'name', 'latitude', 'longitude', 'geom')
        .select('count(samples_map.id) as count')
        .joins('JOIN samples_map ON ST_DWithin ' \
        '(places.geom::geography, samples_map.geom::geography, 1000)')
        .group('id', 'name', 'latitude', 'longitude', 'geom')
        .order(:name)
    end
  end

  def place
    @place ||= Place.find(params[:id])
  end

  def redirect_show
    redirect_to place_page_url(
      place_id: params[:id], id: place.default_page.slug
    )
  end
end
