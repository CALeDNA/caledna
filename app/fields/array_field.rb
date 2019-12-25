# frozen_string_literal: true

require 'administrate/field/base'

class ArrayField < Administrate::Field::Base
  def to_s
    data
  end

  def select_field_values
    models.map do |m|
      if attribute == :primers
        [m.name, m.name]
      else
        [m, m]
      end
    end
  end

  def selected_ids
    data
  end

  private

  def models
    field_name = attribute
    if field_name == :primers
      Primer.all
    elsif field_name == :environmental_features
      KoboValues::ENVIRONMENTAL_FEATURES
    elsif field_name == :environmental_settings
      KoboValues::ENVIRONMENTAL_SETTINGS
    else
      raise StandardError, 'must define model in ArrayField.rb'
    end
  end
end
