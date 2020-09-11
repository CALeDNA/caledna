# frozen_string_literal: true

class EventsController < ApplicationController
  layout 'river/application' if CheckWebsite.pour_site?

  def index
    @events = show_past? ? past_events : Event.upcoming
  end

  def show
    @event = Event.find(params[:id])
  end

  private

  def past_events
    Event.past.where("start_date > '2020-05-01'")
  end

  def show_past?
    params[:type] == 'past'
  end
end
