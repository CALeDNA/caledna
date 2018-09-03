# frozen_string_literal: true

module ControllerHelpers
  def login_researcher
    @request.env['devise.mapping'] = Devise.mappings[:researcher]
    sign_in create(:researcher)
  end

  def login_director
    @request.env['devise.mapping'] = Devise.mappings[:researcher]
    sign_in create(:director)
  end

  def login_user
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in create(:user)
  end
end
