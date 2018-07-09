# frozen_string_literal: true

class ReseedDatabasePolicy < ApplicationPolicy
  def delete?
    user.director? && !Rails.env.production?
  end
end
