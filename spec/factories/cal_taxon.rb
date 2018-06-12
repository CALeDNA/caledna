# frozen_string_literal: true

FactoryBot.define do
  factory :cal_taxon do
    kingdom { Faker::Team.creature }
    phylum 'Tardigrada'
    parentNameUsageID { Faker::Number.number(5) }
    canonicalName { Faker::Team.creature }
    taxonRank 'kingdom'
    taxonomicStatus 'accepted'
    taxonID { Faker::Number.number(5) }
  end
end
