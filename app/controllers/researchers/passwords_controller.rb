# frozen_string_literal: true

module Researchers
  class PasswordsController < Devise::PasswordsController
    layout 'river/application'

    def after_resetting_password_path_for(resource)
      sign_in = Devise.sign_in_after_reset_password
      sign_in ? admin_root_path : new_session_path(resource)
    end
  end
end
