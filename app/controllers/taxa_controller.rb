# frozen_string_literal: true

class TaxaController < ApplicationController
  include CustomPagination

  def index
    @top_plant_taxa = top_plant_taxa
    @top_animal_taxa = top_animal_taxa
  end

  def show
    @taxon = taxon
    @samples = samples
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
    SELECT ARRAY_AGG(DISTINCT(ncbi_names.name)) as common_names,
    ARRAY_AGG(DISTINCT eol_image) AS eol_images,
    ARRAY_AGG(DISTINCT inat_image) AS inat_images,
    ARRAY_AGG(DISTINCT wikidata_image) AS wikidata_images,
    ncbi_nodes.taxon_id, ncbi_nodes.canonical_name, ncbi_nodes.asvs_count,
    ncbi_nodes.hierarchy_names
    FROM "ncbi_nodes"
    JOIN "external_resources"
       ON "external_resources"."ncbi_id" = "ncbi_nodes"."taxon_id"
    LEFT JOIN ncbi_names
      ON ncbi_names.taxon_id = ncbi_nodes.taxon_id
      AND ncbi_names.name_class IN ('common name', 'genbank common name')
    WHERE "ncbi_nodes"."rank" = 'species'
    AND (asvs_count > 0)
    #{kingdom_sql}
    GROUP BY ncbi_nodes.taxon_id, ncbi_nodes.canonical_name,
    ncbi_nodes.asvs_count
    ORDER BY "ncbi_nodes"."asvs_count" DESC
    LIMIT 12;
    SQL
  end

  def plants_sql
    division = NcbiDivision.find_by(name: 'Plantae')
    return if division.blank?

    kingdom_sql = <<-SQL
      AND ncbi_nodes.cal_division_id = #{division.id}
      AND (hierarchy_names ->> 'phylum' = 'Streptophyta')
    SQL
    top_sql(kingdom_sql)
  end

  def animals_sql
    division = NcbiDivision.find_by(name: 'Animalia')
    return if division.blank?

    kingdom_sql = <<-SQL
      AND ncbi_nodes.cal_division_id = #{division.id}
      AND (hierarchy_names ->> 'kingdom' = 'Metazoa')
    SQL
    top_sql(kingdom_sql)
  end

  #================
  # show
  #================

  def join_ncbi_names_sql
    <<-SQL
    LEFT JOIN ncbi_names
      ON ncbi_names.taxon_id = ncbi_nodes.taxon_id
      AND ncbi_names.name_class IN ('common name', 'genbank common name')
    SQL
  end

  def taxon
    @taxon ||= begin
      NcbiNode.joins(join_ncbi_names_sql)
              .select('ARRAY_AGG(DISTINCT(ncbi_names.name)) as common_names')
              .select('ncbi_nodes.*')
              .group('ncbi_nodes.taxon_id, ncbi_nodes.canonical_name')
              .find(params[:id])
    end
  end

  def samples
    if params[:view]
      paginated_samples
    else
      OpenStruct.new(total_records: total_records)
    end
  end

  def samples_sql
    <<-SQL
      SELECT samples.id, samples.barcode, status_cd AS status,
      samples.latitude, samples.longitude,
      array_agg(ncbi_nodes.canonical_name || ' | ' || ncbi_nodes.taxon_id)
      AS taxa
      FROM asvs
      JOIN ncbi_nodes ON asvs."taxonID" = ncbi_nodes."taxon_id"
      JOIN samples ON samples.id = asvs.sample_id
      WHERE ids @> '{#{conn.quote(id)}}'
      GROUP BY samples.id
      LIMIT $1 OFFSET $2;
    SQL
  end

  def paginated_samples
    bindings = [[nil, limit], [nil, offset]]
    raw_records = conn.exec_query(samples_sql, 'query', bindings)
    records = raw_records.map { |r| OpenStruct.new(r) }

    add_pagination_methods(records)
    records
  end

  def total_records
    @total_records ||= begin
      NcbiNode.find_by(taxon_id: id).asvs_count
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
