# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    klass =
      record.class == Symbol ? record.to_s.camelize.constantize : record.class
    Pundit.policy_scope!(user, klass)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  private

  def admin_roles
    user.superadmin? || user.director?
  end

  def upper_level_roles
    user.superadmin? || user.director? || user.esie_postdoc?
  end

  def all_roles
    user.superadmin? || user.director? || user.esie_postdoc? || user.researcher?
  end
end
