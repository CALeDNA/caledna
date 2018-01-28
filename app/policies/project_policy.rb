# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def index?
    all_roles
  end

  def show?
    all_roles
  end

  def create?
    user.is_director?
  end

  def update?
    user.is_director?
  end

  def destroy?
    user.is_director?
  end
end
