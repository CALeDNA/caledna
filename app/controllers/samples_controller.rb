# frozen_string_literal: true

class SamplesController < ApplicationController
  include AsvTreeFormatter
  include CheckWebsite
  layout 'river/application' if CheckWebsite.pour_site?

  def index
    @samples_count = website_sample.approved.with_coordinates.count
    @samples_with_results_count = website_sample.results_completed.count
    @taxa_count = website_asv.select('DISTINCT(taxon_id)').count
  end

  def show
    @division_counts = division_counts
    @sample = sample
    @organisms = organisms
    @asv_tree = asv_tree_data
  end

  private

  def website_sample
    CheckWebsite.caledna_site? ? Sample : Sample.la_river
  end

  def website_asv
    CheckWebsite.caledna_site? ? Asv : Asv.la_river
  end


  # =======================
  # show
  # =======================

  def organisms_sql
    <<-SQL
      SELECT canonical_name,
      hierarchy_names,
      ncbi_nodes.taxon_id, iucn_status,
      ncbi_divisions.name AS division_name, rank,
      common_names
      FROM ncbi_nodes
      JOIN asvs ON asvs.taxon_id = ncbi_nodes.taxon_id
      JOIN ncbi_divisions
        ON ncbi_nodes.cal_division_id = ncbi_divisions.id
      LEFT JOIN external_resources
        ON external_resources.ncbi_id = ncbi_nodes.taxon_id
      WHERE asvs.sample_id = $1
      GROUP BY ncbi_nodes.taxon_id, external_resources.iucn_status,
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

  def organisms
    @organisms ||= begin
      sql = organisms_sql

      binding = [[nil, params[:id]]]
      raw_records = ActiveRecord::Base.connection.exec_query(sql, 'q', binding)
      raw_records.map { |r| OpenStruct.new(r) }
    end
  end

  def division_counts
    @division_counts ||= begin
      Asv.joins(ncbi_node: :ncbi_division)
         .select(:name)
         .where(sample: sample)
         .group(:name)
         .count
    end
  end

  def website_sample
    CheckWebsite.caledna_site? ? Sample : Sample.la_river
  end

  def sample
    @sample ||= website_sample.approved.with_coordinates.find(params[:id])
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
