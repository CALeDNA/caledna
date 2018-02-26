# frozen_string_literal: true

module Labwork
  class AssignSamplesPolicy < Struct.new(:user, :import_kobo)
    def index?
      user.director? || user.lab_manager?
    end

    def create?
      user.director? || user.lab_manager?
    end
  end
end
