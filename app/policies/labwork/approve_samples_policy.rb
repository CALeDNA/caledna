# frozen_string_literal: true

module Labwork
  class ApproveSamplesPolicy < ApplicationPolicy
    def index?
      all_roles
    end

    def create?
      all_roles
    end
  end
end
