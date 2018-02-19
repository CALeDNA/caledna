# frozen_string_literal: true

module Labwork
  class ApproveSamplesPolicy < Struct.new(:user, :import_kobo)
    def index?
      user.director?
    end

    def create?
      user.director?
    end
  end
end
