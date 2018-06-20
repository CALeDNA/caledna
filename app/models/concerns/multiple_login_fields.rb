# frozen_string_literal: true

# Override Devise logic for logging in with username or email
# https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address
module MultipleLoginFields
  extend ActiveSupport::Concern

  included do
    attr_writer :login
  end

  def login
    @login || username || email
  end

  module ClassMethods
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def custom_find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      if (login = conditions.delete(:login))
        where(conditions.to_h).where(
          [
            'lower(username) = :value OR lower(email) = :value',
            { value: login.downcase }
          ]
        ).first
      elsif conditions.key?(:username) || conditions.key?(:email)
        conditions[:email]&.downcase!
        conditions[:username]&.downcase!
        where(conditions.to_h).first
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end
