# frozen_string_literal: true

FactoryBot.define do
  factory :cal_taxon do
    kingdom 'Animalia'
    phylum 'Tardigrada'
    parentNameUsageID { Faker::Number }
    canonicalName 'Animalia'
    taxonRank 'kingdom'
    taxonomicStatus 'accepted'
    taxonID { Faker::Number }
  end
end
