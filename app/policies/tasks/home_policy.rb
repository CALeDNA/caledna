# frozen_string_literal: true

module Tasks
  class HomePolicy < ApplicationPolicy
    def index?
      all_roles
    end
  end
end
