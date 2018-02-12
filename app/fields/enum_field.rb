# frozen_string_literal: true

require 'administrate/field/base'

class EnumField < Administrate::Field::Base
  def to_s
    data.to_s
  end

  def select_field_values(form_builder)
    field_name = attribute.to_s.sub('_cd', '')
    fields = form_builder.object.class.public_send(field_name.pluralize)
    options = [["Select #{field_name.titleize}", '']]
    options + fields.keys.map do |v|
      [v.titleize, v]
    end
  end
end
