# frozen_string_literal: true

class ImportKoboPolicy < Struct.new(:user, :import_kobo)
  def import_kobo?
    user.is_director?
  end

  def import_projects?
    user.is_director?
  end

  def import_samples?
    user.is_director?
  end
end
