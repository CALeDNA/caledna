# frozen_string_literal: true

module CommonNames
  def format_common_names(names, parenthesis: true, truncate: true,
                          first_only: false)
    return if names.blank?

    names = names.split('|')
    if first_only
      name = names.first
      parenthesis ? "(#{name})" : name
    elsif parenthesis
      truncate ? "(#{common_names_string(names)})" : "(#{names.join(', ')})"
    else
      truncate ? common_names_string(names) : names.join(', ')
    end
  end

  private

  def common_names_string(names)
    max = 3
    names.count > max ? "#{names.take(max).join(', ')}..." : names.join(', ')
  end
end
