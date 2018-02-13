# frozen_string_literal: true

class SamplePolicy < ApplicationPolicy
  def index?
    all_roles
  end

  def show?
    all_roles
  end

  def create?
    user.director?
  end

  def update?
    user.director? || user.lab_manager?
  end

  def destroy?
    user.director?
  end
end
