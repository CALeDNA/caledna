# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController
    layout 'river/application' if CheckWebsite.pour_site?
  end
end
