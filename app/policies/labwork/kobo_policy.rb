# frozen_string_literal: true

module Labwork
  class KoboPolicy < Struct.new(:user, :kobo)
    def import_kobo?
      user.director?
    end

    def import_projects?
      user.director?
    end

    def import_samples?
      user.director?
    end
  end
end
