# frozen_string_literal: true

class AsvPolicy < ApplicationPolicy
  def index?
    all_roles
  end

  def show?
    all_roles
  end

  def update?
    admin_roles
  end

  def destroy?
    admin_roles
  end
end
