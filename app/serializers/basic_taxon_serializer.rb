# frozen_string_literal: true

class BasicTaxonSerializer
  include FastJsonapi::ObjectSerializer
  attributes :common_names, :canonical_name
end
