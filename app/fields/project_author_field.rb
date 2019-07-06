# frozen_string_literal: true

require 'administrate/field/base'

class ProjectAuthorField < Administrate::Field::Base
  def to_s
    data.pluck(:username).join(', ')
  end

  def select_field_values
    field_name = attribute.to_s.sub('_authors', '')
    model = if field_name == 'researcher'
              Researcher
            else
              User
            end

    options = [["Select #{model.name}", '']]
    options + model.all.map do |m|
      [m.username, m.id]
    end
  end

  def selected_ids
    data.pluck(:id)
  end
end
