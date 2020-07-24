# frozen_string_literal: true

module Researchers
  class SessionsController < Devise::SessionsController
    layout 'river/application'

    def after_sign_in_path_for(_)
      admin_root_path
    end
  end
end
