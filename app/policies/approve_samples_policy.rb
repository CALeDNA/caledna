# frozen_string_literal: true

class ApproveSamplesPolicy < Struct.new(:user, :import_kobo)
  def index?
    user.is_director?
  end

  def create?
    user.is_director?
  end
end
