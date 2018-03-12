# frozen_string_literal: true

module Labwork
  class NormalizeTaxonPolicy < ApplicationPolicy
    def index?
      user.director? || user.lab_manager?
    end

    def show?
      user.director? || user.lab_manager?
    end

    def create?
      user.director? || user.lab_manager?
    end
  end
end
