# frozen_string_literal: true

module ApplicationHelper
  include CheckWebsite

  def caledna_site?
    CheckWebsite.caledna_site?
  end

  def pour_site?
    CheckWebsite.pour_site?
  end

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

  def percentage(value, totals)
    return if value.nil?
    percent = (value.to_f / totals) * 100
    format('%.2f', percent)
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

  def nav_link(text, path)
    normalized_path = path.start_with?('/') ? path : "/#{path}"
    options = current_page?(normalized_path) ? { class: 'active' } : {}

    content_tag(:li, options) do
      link_to text, path
    end
  end

  def about_active?
    paths = []
    if CheckWebsite.pour_site?
      paths = [faq_path, our_mission_path, our_team_path,
               why_protect_biodiversity_path]
    end
    dropdown_active?(paths)
  end

  def explore_data_active?
    paths = [samples_path, research_projects_path, taxa_path]
    paths << field_projects_path if CheckWebsite.caledna_site?
    dropdown_active?(paths)
  end

  def news_active?
    paths = []
    paths = [site_news_index_path] if CheckWebsite.pour_site?
    dropdown_active?(paths)
  end

  # rubocop:disable Naming/AccessorMethodName
  def get_involved_active?
    paths = if CheckWebsite.caledna_site?
              [events_path]
            else
              [get_involved_path]
            end
    dropdown_active?(paths)
  end
  # rubocop:enable Naming/AccessorMethodName

  def dropdown_active?(paths)
    paths.any? { |p| request.fullpath.start_with? p }
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

  def pill_menu_classes(active)
    active ? 'btn btn-default active' : 'btn btn-default'
  end

  # NOTE: can't access image_tag from custom module helpers
  # rubocop:disable Metrics/MethodLength
  def display_option_collection(question)
    question.survey_options.order(:id).map do |option|
      if option.photo.attachment.present?
        [
          "#{option.content}<br> " \
          "#{image_tag(option.photo, class: 'question-photo')}".html_safe,
          option.id
        ]
      else
        [option.content, option.id]
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
end
