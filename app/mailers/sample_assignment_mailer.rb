# frozen_string_literal: true

class SampleAssignmentMailer < ApplicationMailer
  def new_samples(mail_data)
    data = JSON.parse(mail_data)
    @name = data['name']
    @samples_count = data['samples_count']
    mail(to: data['email'], subject: 'New samples need to be processed')
  end
end
