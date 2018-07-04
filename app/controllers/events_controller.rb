# frozen_string_literal: true

class EventsController < ApplicationController
  def index
    @events = show_past? ? Event.past : Event.upcoming
  end

  def show
    @event = Event.find(params[:id])
  end

  private

  def show_past?
    params[:type] == 'past'
  end
end
