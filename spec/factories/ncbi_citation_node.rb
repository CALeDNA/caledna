# frozen_string_literal: true

FactoryBot.define do
  factory :ncbi_citation_node do
    ncbi_citation
    ncbi_node
  end
end
