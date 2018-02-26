# frozen_string_literal: true

class FieldDataProjectPolicy < ApplicationPolicy
  def index?
    all_roles
  end

  def show?
    all_roles
  end


  def update?
    user.director?
  end

  def destroy?
    user.director?
  end
end
