# frozen_string_literal: true

module AdminFullForm
  private

  def resolve_layout
    case action_name
    when 'new', 'edit'
      'admin/full_form'
    else
      'administrate/application'
    end
  end
end
