# frozen_string_literal: true

class Page < ApplicationRecord
  as_enum :menu, %i[
    about
    explore_data
    get_involved
    get_involved_community_scientist
    get_involved_analyze_data
    get_involved_caledna_network
  ], map: :string
end
