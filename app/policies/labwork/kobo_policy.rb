# frozen_string_literal: true

module Labwork
  class KoboPolicy < ApplicationPolicy
    def import_kobo?
      all_roles
    end

    def import_projects?
      all_roles
    end

    def import_samples?
      all_roles
    end
  end
end
