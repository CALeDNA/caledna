# frozen_string_literal: true

class SampleAssignmentWorker
  include Sidekiq::Worker

  def perform(mail_data)
    SampleAssignmentMailer.new_samples(mail_data).deliver
  end
end
