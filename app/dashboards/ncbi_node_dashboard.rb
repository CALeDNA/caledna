require "administrate/base_dashboard"

class NcbiNodeDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    ncbi_names: Field::HasMany,
    ncbi_citation_nodes: Field::HasMany,
    ncbi_citations: Field::HasMany,
    ncbi_division: Field::BelongsTo,
    asvs: Field::HasMany,
    taxon_id: Field::Number,
    parent_taxon_id: Field::Number,
    rank: Field::String,
    embl_code: Field::String,
    division_id: Field::Number,
    inherited_division: Field::Boolean,
    genetic_code_id: Field::Number,
    inherited_genetic_code: Field::Boolean,
    mitochondrial_genetic_code_id: Field::Number,
    inherited_mitochondrial_genetic_code: Field::Boolean,
    genbank_hidden: Field::Boolean,
    hidden_subtree_root: Field::Boolean,
    comments: Field::Text,
    canonical_name: Field::String,
    lineage: Field::Text,
    hierarchy: Field::String.with_options(searchable: false),
    full_taxonomy_string: Field::Text,
    short_taxonomy_string: Field::Text,
    cal_division_id: Field::Number,
    asvs_count: Field::Number,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :ncbi_names,
    :ncbi_citation_nodes,
    :ncbi_citations,
    :ncbi_division,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :ncbi_names,
    :ncbi_citation_nodes,
    :ncbi_citations,
    :ncbi_division,
    :asvs,
    :taxon_id,
    :parent_taxon_id,
    :rank,
    :embl_code,
    :division_id,
    :inherited_division,
    :genetic_code_id,
    :inherited_genetic_code,
    :mitochondrial_genetic_code_id,
    :inherited_mitochondrial_genetic_code,
    :genbank_hidden,
    :hidden_subtree_root,
    :comments,
    :canonical_name,
    :lineage,
    :hierarchy,
    :full_taxonomy_string,
    :short_taxonomy_string,
    :cal_division_id,
    :asvs_count,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
  ].freeze


  def display_resource(ncbi_node)
    ncbi_node.canonical_name
  end
end
