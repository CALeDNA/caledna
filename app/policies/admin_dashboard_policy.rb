# frozen_string_literal: true

class AdminDashboardPolicy < ApplicationPolicy
  def superadmin?
    user.superadmin?
  end

  def admin?
    admin_roles
  end

  def upper_level?
    upper_level_roles
  end

  def all?
    all_roles
  end
end
