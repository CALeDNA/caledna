# frozen_string_literal: true

class TaxaController < ApplicationController
  def index
    @top_plant_taxa = top_plant_taxa
    @top_animal_taxa = top_animal_taxa

    @taxa_count = Asv.select('DISTINCT(taxon_id)').count
    join_sql = 'JOIN ncbi_nodes on ncbi_nodes.taxon_id = asvs.taxon_id'
    @families_count = families_count
    @species_count = species_count
  end

  def show
    @taxon = taxon
    @children = children
    @total_records = total_records
  end

  private

  #================
  # index
  #================

  def top_plant_taxa
    @top_plant_taxa ||= begin
      return [] if plants_sql.blank?

      results = conn.exec_query(plants_sql)
      results.map { |r| OpenStruct.new(r) }
    end
  end

  def top_animal_taxa
    @top_animal_taxa ||= begin
      return [] if animals_sql.blank?

      results = conn.exec_query(animals_sql)
      results.map { |r| OpenStruct.new(r) }
    end
  end

  def top_sql(kingdom_sql = nil)
    <<-SQL
    SELECT
    ARRAY_AGG(DISTINCT eol_image) AS eol_images,
    ARRAY_AGG(DISTINCT inat_image) AS inat_images,
    ARRAY_AGG(DISTINCT wikidata_image) AS wikidata_images,
    ncbi_nodes.taxon_id, ncbi_nodes.canonical_name, ncbi_nodes.asvs_count,
    ncbi_nodes.hierarchy_names, ncbi_nodes.common_names,
    ncbi_divisions.name as division_name
    FROM "ncbi_nodes"
    LEFT JOIN "external_resources"
       ON "external_resources"."ncbi_id" = "ncbi_nodes"."ncbi_id"
    JOIN ncbi_divisions
      ON ncbi_nodes.cal_division_id = ncbi_divisions.id
    WHERE "ncbi_nodes"."rank" = 'species'
    AND (asvs_count > 5)
    #{kingdom_sql}
    GROUP BY ncbi_nodes.taxon_id, ncbi_nodes.canonical_name,
    ncbi_nodes.asvs_count, ncbi_divisions.name
    ORDER BY "ncbi_nodes"."asvs_count" DESC
    LIMIT 12;
    SQL
  end

  def plants_sql
    kingdom_sql = <<-SQL
      AND (hierarchy_names @> '{"phylum":"Streptophyta"}')
    SQL
    top_sql(kingdom_sql)
  end

  def animals_sql
    kingdom_sql = <<-SQL
      AND (hierarchy_names @> '{"kingdom": "Metazoa"}')
    SQL
    top_sql(kingdom_sql)
  end

  #================
  # show
  #================

  def families_count
    @families_count ||= begin
      results = conn.exec_query(rank_count('family'))
      results.entries[0]['count']
    end
  end

  def species_count
    @species_count ||= begin
      results = conn.exec_query(rank_count('species'))
      results.entries[0]['count']
    end
  end

  def rank_count(rank)
    <<-SQL
    SELECT COUNT(DISTINCT(hierarchy_names ->> '#{rank}'))
    FROM ncbi_nodes
    WHERE taxon_id IN (
      SELECT taxon_id FROM asvs GROUP BY taxon_id
    );
    SQL
  end

  def taxon
    @taxon ||= NcbiNode.find(params[:id])
  end

  def children
    @children ||= begin
      NcbiNode.where(parent_taxon_id: taxon.ncbi_id)
              .order('canonical_name')
              .page(params[:children_page])
              .per(10)
    end
  end

  def total_records
    @total_records ||= begin
      NcbiNode.find_by(taxon_id: id).asvs_count || 0
    end
  end

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  def id
    params[:id].to_i
  end

  def query_string
    {}
  end
end
