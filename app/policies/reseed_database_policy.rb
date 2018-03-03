# frozen_string_literal: true

class ReseedDatabasePolicy < ApplicationPolicy
  def delete?
    user.director?
  end
end
