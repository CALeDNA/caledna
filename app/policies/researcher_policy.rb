# frozen_string_literal: true

class ResearcherPolicy < ApplicationPolicy
  def index?
    all_roles
  end

  def show?
    all_roles
  end

  def access_show?
    user.director? || user.lab_manager?
  end

  def create?
    user.director?
  end

  def update?
    user.director?
  end

  def destroy?
    user.director?
  end
end
