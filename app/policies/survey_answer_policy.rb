# frozen_string_literal: true

class SurveyAnswerPolicy < ApplicationPolicy
  def index?
    user.director?
  end

  def show?
    user.director?
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
