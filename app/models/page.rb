# frozen_string_literal: true

class Page < ApplicationRecord
  as_enum :menu, %i[
    about_the_project
    explore_data
    before_you_begin
    join_us
    contact
  ], map: :string
end
