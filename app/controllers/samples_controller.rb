# frozen_string_literal: true

class SamplesController < ApplicationController
  include AsvTreeFormatter
  include CheckWebsite
  include FilterSamples

  layout 'river/application' if CheckWebsite.pour_site?

  def index
    @samples_count = approved_samples_count
    @samples_with_results_count = completed_samples_count
    @taxa_count = taxa_count
  end

  def show
    @division_counts = division_counts
    @sample = sample
    @organisms = organisms
    @asv_tree = asv_tree_data
  end

  private

  # =======================
  # show
  # =======================

  # rubocop:disable Metrics/MethodLength
  def organisms_sql
    sql = <<~SQL
      SELECT canonical_name,
      hierarchy_names,
      ncbi_nodes.taxon_id, ncbi_nodes.iucn_status,
      ncbi_divisions.name AS division_name, rank,
      common_names
      FROM ncbi_nodes
      JOIN asvs ON asvs.taxon_id = ncbi_nodes.taxon_id
      JOIN ncbi_divisions
        ON ncbi_nodes.cal_division_id = ncbi_divisions.id
      WHERE asvs.sample_id = $1
    SQL

    if CheckWebsite.pour_site?
      sql += "AND research_project_id = #{ResearchProject::LA_RIVER.id}"
    end

    sql + <<~SQL
      GROUP BY ncbi_nodes.taxon_id, ncbi_nodes.iucn_status,
      ncbi_divisions.name
      ORDER BY division_name,
      hierarchy_names ->>'phylum',
      hierarchy_names ->>'class',
      hierarchy_names ->>'order',
      hierarchy_names ->>'family',
      hierarchy_names ->>'genus',
      hierarchy_names ->>'species';
    SQL
  end
  # rubocop:enable Metrics/MethodLength

  def organisms
    @organisms ||= begin
      binding = [[nil, params[:id]]]
      raw_records = conn.exec_query(organisms_sql, 'q', binding)
      raw_records.map { |r| OpenStruct.new(r) }
    end
  end

  def division_counts_sql
    <<~SQL
      SELECT COUNT(*) AS count_name, name
      FROM asvs
      JOIN ncbi_nodes ON ncbi_nodes.taxon_id = asvs.taxon_id
      JOIN ncbi_divisions ON ncbi_divisions.id = ncbi_nodes.cal_division_id
      WHERE asvs.sample_id = #{sample.id}
      GROUP BY name;
    SQL
  end

  def division_counts
    @division_counts ||= begin
      counts = {}
      conn.exec_query(division_counts_sql).each do |record|
        counts[record['name']] = record['count_name'].to_i
      end
      counts
    end
  end

  def sample
    @sample ||= begin
      website_sample
        .select('samples.*')
        .joins(results_left_join_sql)
        .joins(optional_published_research_project_sql)
        .where(conditional_status_sql)
        .group(:id)
        .find(params[:id])
    end
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

  def conn
    ActiveRecord::Base.connection
  end
end
