# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    all_roles
  end

  def show?
    all_roles
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
