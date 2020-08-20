# frozen_string_literal: true

class PlaceSourcePolicy < ApplicationPolicy
  def index?
    user.superadmin?
  end

  def show?
    user.superadmin?
  end

  def create?
    user.superadmin?
  end

  def update?
    user.superadmin?
  end

  def destroy?
    user.superadmin?
  end
end
