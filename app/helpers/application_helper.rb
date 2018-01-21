# frozen_string_literal: true

module ApplicationHelper
  # NOTE: can't use "l(field) format: :short" because it crashes if field is nil
  def long_date(date)
    format_date(date, I18n.t('time.formats.long'))
  end

  def short_date(date)
    format_date(date, I18n.t('time.formats.short'))
  end

  def format_date(date, format)
    return unless date.present?
    date.strftime(format)
  end
end
