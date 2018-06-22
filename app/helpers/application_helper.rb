# frozen_string_literal: true

module ApplicationHelper
  # NOTE: can't use "l(field) format: :short" because it crashes if field is nil
  def long_date(date)
    format_date(date, I18n.t('time.formats.long'))
  end

  def short_date(date)
    format_date(date, I18n.t('time.formats.short'))
  end

  def long_datetime(date)
    format_date(date, I18n.t('time.formats.long_datetime'))
  end

  def format_date(date, format)
    return unless date.present?
    date.strftime(format)
  end

  def render_admin_field(type, field, locals = {})
    locals[:field] = field
    render locals: locals, partial: "admin/form/admin_#{type}_field"
  end

  def select_field_values(field, options_values)
    field_name = field.to_s
    options = [["Select #{field_name.titleize}", '']]
    options + options_values
  end

  def enum_field_values(field, enum_values)
    field_name = field.to_s.sub('_cd', '')
    options = [["Select #{field_name.titleize}", '']]
    options + enum_values.map do |k, v|
      [k.titleize, v]
    end
  end

  def flash_class(type)
    case type
    when 'alert' then 'alert alert-danger'
    when 'failure' then 'alert alert-danger'
    when 'success' then 'alert alert-success'
    when 'notice' then 'alert alert-success'
    else 'alert alert-light'
    end
  end
end
