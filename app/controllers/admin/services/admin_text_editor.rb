# frozen_string_literal: true

module AdminTextEditor
  private

  def resolve_layout
    case action_name
    when 'new', 'edit'
      'admin/text_editor'
    else
      'administrate/application'
    end
  end
end
