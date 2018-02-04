# frozen_string_literal: true

FactoryBot.define do
  factory :speciman, class: 'Specimen' do
    sample
    taxonomic_unit
  end
end
