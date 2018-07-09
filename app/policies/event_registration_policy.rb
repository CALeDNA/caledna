# frozen_string_literal: true

class EventRegistrationPolicy < ApplicationPolicy
  def index?
    all_roles
  end

  def show?
    all_roles
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
