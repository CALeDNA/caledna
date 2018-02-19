# frozen_string_literal: true

module Labwork
  class HomePolicy < ApplicationPolicy
    def index?
      all_roles
    end
  end
end
