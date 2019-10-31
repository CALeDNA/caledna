# frozen_string_literal: true

class PrimerPolicy < ApplicationPolicy
  def index?
    all_roles
  end

  def show?
    all_roles
  end

  def update?
    all_roles
  end

  def destroy?
    user.director?
  end
end
