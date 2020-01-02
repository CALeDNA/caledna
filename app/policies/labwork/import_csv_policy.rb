# frozen_string_literal: true

module Labwork
  class ImportCsvPolicy < ApplicationPolicy
    def index?
      all_roles
    end

    def create?
      all_roles
    end
  end
end
