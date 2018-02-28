# frozen_string_literal: true

class ReseedDatabasePolicy < ApplicationPolicy
  def show?
    user.director?
  end
end
