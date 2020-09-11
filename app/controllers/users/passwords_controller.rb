# frozen_string_literal: true

module Users
  class PasswordsController < Devise::PasswordsController
    layout 'river/application' if CheckWebsite.pour_site?
  end
end
