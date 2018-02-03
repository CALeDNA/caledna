# frozen_string_literal: true

class ImportKoboPolicy < Struct.new(:user, :import_kobo)
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
