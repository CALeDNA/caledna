# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    upper_level_roles
  end

  def show?
    upper_level_roles
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
