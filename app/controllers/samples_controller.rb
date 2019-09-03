# frozen_string_literal: true

class SamplesController < ApplicationController
  include PaginatedSamples
  include BatchData
  include AsvTreeFormatter

  def index
    @samples = samples
    @asvs_count = counts
  end

  def show
    @division_counts = division_counts
    @sample = sample
    @organisms = organisms
    @asv_tree = asv_tree_data
  end

  private

  # =======================
  # index
  # =======================

  def counts
    @counts ||= list_view? ? asvs_count : []
  end

  def samples
    @samples ||= list_view? ? paginated_samples : []
  end

  # =======================
  # show
  # =======================

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def organisms
    @organisms ||= begin
      NcbiNode.joins(:asvs)
              .joins('JOIN ncbi_divisions on ncbi_nodes.cal_division_id = ' \
                'ncbi_divisions.id')
              .joins('LEFT JOIN external_resources ON ' \
                'external_resources.ncbi_id = ncbi_nodes.taxon_id')
              .joins('LEFT JOIN ncbi_names ON ncbi_names.taxon_id = ' \
                'ncbi_nodes.taxon_id ' \
                'AND ncbi_names.name_class IN ' \
                "('common name', 'genbank common name')")
              .select('hierarchy_names, ncbi_nodes.taxon_id, ' \
                'iucn_status, ncbi_divisions.name as cal_kingdom, rank')
              .select('ARRAY_AGG(DISTINCT(ncbi_names.name)) as common_names')
              .group('ncbi_nodes.taxon_id, ' \
                'iucn_status, ncbi_divisions.name')
              .where('asvs.sample_id = ?', sample.id)
              .order('cal_kingdom')
              .order("hierarchy_names ->>'phylum'")
              .order("hierarchy_names ->>'class'")
              .order("hierarchy_names ->>'order'")
              .order("hierarchy_names ->>'family'")
              .order("hierarchy_names ->>'genus'")
              .order("hierarchy_names ->>'species'")
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def division_counts
    @division_counts ||= begin
      Asv.joins(ncbi_node: :ncbi_division)
         .select(:name)
         .where(sample: sample)
         .group(:name)
         .count
    end
  end

  def sample
    @sample ||= Sample.approved.with_coordinates.find(params[:id])
  end

  def asv_tree_taxa
    @asv_tree_taxa ||= fetch_asv_tree_for_sample(sample.id)
  end

  def asv_tree_data
    tree = asv_tree_taxa.map do |taxon|
      taxon_object = create_taxon_object(taxon)
      create_tree_objects(taxon_object, taxon.rank)
    end.flatten
    tree << { 'name': 'Life', 'id': 'Life', 'common_name': nil }
    tree.uniq! { |i| i[:id] }
  end
end
