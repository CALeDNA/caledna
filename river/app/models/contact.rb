# frozen_string_literal: true

class Contact < MailForm::Base
  attribute :name, validate: true
  attribute :email, validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :message, validate: true
  attribute :subject, validate: true

  def headers
    {
      subject: subject,
      to: ENV.fetch('POUR_EMAIL'),
      from: %("#{name}" <#{email}>)
    }
  end
end
