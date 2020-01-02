# frozen_string_literal: true

module ValidUserRequestHelper
  def login_director
    login(FactoryBot.create(:director))
  end

  def login_researcher
    login(FactoryBot.create(:researcher))
  end

  def login_esie_postdoc
    login(FactoryBot.create(:esie_postdoc))
  end

  def login_user
    login(FactoryBot.create(:user))
  end

  private

  def login(user)
    login_as(user, scope: :researcher)
  end
end
