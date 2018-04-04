# frozen_string_literal: true

FactoryBot.define do
  factory :cal_taxon do
    kingdom 'Animalia'
    phylum 'Tardigrada'
    parentNameUsageID { Faker::Number.number(5) }
    canonicalName 'Animalia'
    taxonRank 'kingdom'
    taxonomicStatus 'accepted'
    taxonID { Faker::Number.number(5) }
  end
end
