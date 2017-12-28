# frozen_string_literal: true

module ControllerHelpers
  def login_researcher
    @request.env['devise.mapping'] = Devise.mappings[:researcher]
    sign_in FactoryBot.create(:researcher)
  end
end
