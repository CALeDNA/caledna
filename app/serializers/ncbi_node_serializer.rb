# frozen_string_literal: true

class NcbiNodeSerializer
  include FastJsonapi::ObjectSerializer

  attributes :canonical_name, :hierarchy, :ids,
             :rank, :hierarchy_names, :taxon_id, :full_taxonomy_string,
             :division_id, :cal_division_id, :names, :ranks
end
