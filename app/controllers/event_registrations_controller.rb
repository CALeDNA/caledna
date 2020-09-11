# frozen_string_literal: true

class EventRegistrationsController < ApplicationController
  layout 'river/application' if CheckWebsite.pour_site?

  def create
    attrs = { event_id: event_id, user_id: current_user.id,
              status_cd: :registered }
    event = EventRegistration.new(attrs)

    if event.save
      flash[:success] = 'You are registered for the event.'
    else
      flash[:failure] = event.errors.messages.values.join('<br>')
    end
    redirect_to event_path(id: event_id)
  end

  def update_status
    if event_registration.update(status_cd: status)
      flash[:success] = success_message
    else
      flash[:failure] = event.errors.messages.values.join('<br>')
    end
    redirect_to event_path(id: event_id)
  end

  private

  def success_message
    case status
    when 'canceled' then 'Your registration has been canceled.'
    when 'registered' then 'You are registered for the event.'
    end
  end

  def event_registration
    @event_registration ||=
      EventRegistration.where(user: current_user, event_id: event_id).first
  end

  def event_id
    params[:event_id]
  end

  def status
    params[:status]
  end

  # def allowed_params
  #   params.require(:event_registrations).permit(:event_id, :status)
  # end
end
