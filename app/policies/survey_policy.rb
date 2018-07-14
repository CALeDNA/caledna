# frozen_string_literal: true

class SurveyPolicy < ApplicationPolicy
  def index?
    user.director?
  end

  def show?
    user.director?
  end

  def create?
    user.director? || user.lab_manager?
  end

  def update?
    user.director? || user.lab_manager?
  end

  def destroy?
    user.director? || user.lab_manager?
  end
end
