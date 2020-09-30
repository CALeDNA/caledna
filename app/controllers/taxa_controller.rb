# frozen_string_literal: true

class TaxaController < ApplicationController
  include CheckWebsite
  include FilterSamples
  layout 'river/application' if CheckWebsite.pour_site?

  def index
    @top_plant_taxa = top_plant_taxa
    @top_animal_taxa = top_animal_taxa

    @taxa_count = Website.default_site.taxa_count
    @families_count = Website.default_site.families_count
    @species_count = Website.default_site.species_count
  end

  def show
    @taxon = taxon
    @children = children
    @total_records = total_records
    @related_organisms = related_organisms
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

  def website_count
    if CheckWebsite.caledna_site?
      'ncbi_nodes.asvs_count'
    else
      'ncbi_nodes.asvs_count_la_river'
    end
  end

  def top_sql(kingdom_sql = nil)
    <<-SQL
    SELECT
    ARRAY_AGG(DISTINCT gbif_image) AS gbif_images,
    ARRAY_AGG(DISTINCT eol_image) AS eol_images,
    ARRAY_AGG(DISTINCT inat_image) AS inat_images,
    ARRAY_AGG(DISTINCT wikidata_image) AS wikidata_images,
    ncbi_nodes.taxon_id, ncbi_nodes.canonical_name,
    #{website_count} as asvs_count,
    ncbi_nodes.hierarchy_names, ncbi_nodes.common_names,
    ncbi_divisions.name as division_name
    FROM "ncbi_nodes"
    LEFT JOIN "external_resources"
       ON "external_resources"."ncbi_id" = "ncbi_nodes"."ncbi_id"
       AND active = true
    JOIN ncbi_divisions
      ON ncbi_nodes.cal_division_id = ncbi_divisions.id
    WHERE "ncbi_nodes"."rank" = 'species'
    AND (#{website_count} > 3)
    #{kingdom_sql}
    GROUP BY ncbi_nodes.taxon_id, ncbi_nodes.canonical_name,
    #{website_count}, ncbi_divisions.name
    ORDER BY #{website_count} DESC
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

  def taxon
    @taxon ||= NcbiNode.find(params[:id])
  end

  def related_organisms
    @related_organisms ||= begin
      sql =
        'taxon_id in (SELECT taxon_id from asvs where research_project_id = ?)'
      NcbiNode.where('ids @> ARRAY[?]::int[]', params[:id])
              .where('asvs_count_la_river > 0')
              .where(sql, ResearchProject.la_river.id)
              .where('taxon_id != ?', params[:id])
              .page(params[:related_organisms_page])
              .order('canonical_name ASC')
              .per(50)
    end
  end

  def children
    @children ||= begin
      NcbiNode.where(parent_taxon_id: taxon.ncbi_id)
              .order('asvs_count_la_river DESC NULLS LAST, canonical_name ASC')
              .page(params[:children_page])
              .per(10)
    end
  end

  def total_records
    @total_records ||= begin
      if CheckWebsite.caledna_site?
        NcbiNode.find_by(taxon_id: id).asvs_count || 0
      else
        NcbiNode.find_by(taxon_id: id).asvs_count_la_river || 0
      end
    end
  end

  #================
  # common
  #================

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
