# frozen_string_literal: true

module Tasks
  class AggregateCsvPolicy < ApplicationPolicy
    def index?
      all_roles
    end

    def create?
      admin_roles
    end
  end
end
