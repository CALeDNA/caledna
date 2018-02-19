# frozen_string_literal: true

module Labwork
  class ProcessExtractionsPolicy < ApplicationPolicy
    def index?
      all_roles
    end

    def show?
      all_roles
    end

    def create?
      user.director? || user.lab_manager?
    end

    def update?
      all_roles
    end

    def destroy?
      user.director?
    end
  end
end
