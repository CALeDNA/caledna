# frozen_string_literal: true

class PlacesController < ApplicationController
  layout 'river/application' if CheckWebsite.pour_site?

  def index; end

  def show; end
end
