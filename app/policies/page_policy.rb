# frozen_string_literal: true

class PagePolicy < ApplicationPolicy
  def index?
    user.director? || user.lab_manager?
  end

  def show?
    user.director? || user.lab_manager?
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
