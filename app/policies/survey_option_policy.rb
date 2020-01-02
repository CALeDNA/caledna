# frozen_string_literal: true

class SurveyOptionPolicy < ApplicationPolicy
  def index?
    upper_level_roles
  end

  def show?
    upper_level_roles
  end

  def create?
    upper_level_roles
  end

  def update?
    upper_level_roles
  end

  def destroy?
    upper_level_roles
  end
end
