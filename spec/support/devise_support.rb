# frozen_string_literal: true

module ValidUserRequestHelper
  def login_director
    login(FactoryBot.create(:director))
  end

  def login_sample_processor
    login(FactoryBot.create(:sample_processor))
  end

  def login_lab_manager
    login(FactoryBot.create(:lab_manager))
  end

  def login_user
    login(FactoryBot.create(:user))
  end

  private

  def login(user)
    login_as(user, scope: :researcher)
  end
end
