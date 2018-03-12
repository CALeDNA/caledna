# frozen_string_literal: true

class NormalizeTaxa < ApplicationRecord
  as_enum :rank, %i[kingdom phylum class order family genus species], map: :string

  def name
    hierarchy[rank.to_s]
  end
end
