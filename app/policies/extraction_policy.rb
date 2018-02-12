# frozen_string_literal: true

class ExtractionPolicy < ApplicationPolicy
  def index?
    valid_users
  end

  def show?
    valid_users
  end

  def create?
    user.director?
  end

  def update?
    valid_users
  end

  def destroy?
    user.director?
  end

  class Scope < Scope
    def resolve
      scope.all
    end

    # NOTE: resolve_admin affects the number of records shown on index
    def resolve_admin
      if user.sample_processor?
        scope.where(processor: user)
      else
        scope.all
      end
    end
  end

  private

  def valid_users
    # NOTE: scope.where affects if row on the index will show data
    user.director? || user.lab_manager? || scope.where(processor: user)
  end
end
