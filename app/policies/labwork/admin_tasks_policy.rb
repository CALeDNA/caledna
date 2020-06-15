# frozen_string_literal: true

module Labwork
  class AdminTasksPolicy < ApplicationPolicy
    def index?
      admin_roles
    end
  end
end
