# frozen_string_literal: true

class PlacePolicy < ApplicationPolicy
  def index?
    admin_roles
  end

  def show?
    admin_roles
  end

  def create?
    admin_roles
  end

  def update?
    admin_roles
  end

  def destroy?
    admin_roles
  end
end
