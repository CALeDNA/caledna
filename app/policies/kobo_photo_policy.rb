# frozen_string_literal: true

class KoboPhotoPolicy < ApplicationPolicy
  def index?
    all_roles
  end

  def show?
    all_roles
  end

  def destroy?
    admin_roles
  end
end
