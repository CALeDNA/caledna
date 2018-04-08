# frozen_string_literal: true

class ResearchProjectPolicy < ApplicationPolicy
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
    user.director?
  end

  def destroy?
    user.director?
  end
end
