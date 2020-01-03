# frozen_string_literal: true

class FieldProjectPolicy < ApplicationPolicy
  def index?
    all_roles
  end

  def show?
    all_roles
  end

  def create?
    all_roles
  end

  def update?
    all_roles
  end

  def destroy?
    admin_roles
  end
end
