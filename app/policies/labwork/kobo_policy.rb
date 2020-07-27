# frozen_string_literal: true

module Labwork
  class KoboPolicy < ApplicationPolicy
    def import?
      all_roles
    end
  end
end
