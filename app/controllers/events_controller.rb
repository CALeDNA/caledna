# frozen_string_literal: true

class EventsController < ApplicationController
  def index
    @events = show_past? ? past_events : upcoming_events
  end

  def show
    @event = Event.find(params[:id])
  end

  private

  def show_past?
    params[:type] == 'past'
  end

  def upcoming_events
    @upcoming_events ||= Event.where("end_date > '#{Time.zone.now}'")
                              .order(end_date: :desc)
  end

  def past_events
    @past_events ||= Event.where("end_date < '#{Time.zone.now}'")
                          .order(end_date: :desc)
  end
end
