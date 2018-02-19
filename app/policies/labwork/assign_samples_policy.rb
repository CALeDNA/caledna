# frozen_string_literal: true

module Labwork
  class AssignSamplesPolicy < Struct.new(:user, :import_kobo)
    def index?
      user.director?
    end

    def create?
      user.director?
    end
  end
end
