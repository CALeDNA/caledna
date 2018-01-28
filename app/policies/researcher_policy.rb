# frozen_string_literal: true

class ResearcherPolicy < ApplicationPolicy
  def index?
    all_roles
  end

  def show?
    all_roles
  end

  def access_show?
    user.is_director? || user.is_lab_manager?
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
