# frozen_string_literal: true

module Labwork
  class ImportCsvPolicy < ApplicationPolicy
    def index?
      user.director?
    end

    def create?
      user.director?
    end
  end
end
