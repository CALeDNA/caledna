# frozen_string_literal: true

class PlacePagesController < ApplicationController
  layout 'river/application' if CheckWebsite.pour_site?

  def show; end
end
