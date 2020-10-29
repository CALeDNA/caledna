# frozen_string_literal: true

class TaxaSearchesController < ApplicationController
  include CustomPagination
  include CheckWebsite
  layout 'river/application' if CheckWebsite.pour_site?

  def show
    if query
      @matches = matches
      @query = query
    else
      @matches = []
      @query = nil
    end
  end

  def matches
    bindings = [[nil, query], [nil, limit], [nil, offset]]
    raw_records = conn.exec_query(result_sql, 'q', bindings)
    records = raw_records.map { |r| OpenStruct.new(r) }
    add_pagination_methods(records)
    records
  end

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  def result_sql
    <<-SQL
    SELECT taxon_id, canonical_name, rank, asvs_count,
    eol_ids, eol_images,
    inat_ids, inat_images,
    wikidata_images, common_names, division_name
    FROM (
      SELECT ncbi_nodes.taxon_id, ncbi_nodes.canonical_name, ncbi_nodes.rank,
      ncbi_divisions.name as division_name,
      asvs_count, common_names,
      ARRAY_AGG(DISTINCT eol_id) AS eol_ids,
      ARRAY_AGG(DISTINCT eol_image) AS eol_images,
      ARRAY_AGG(DISTINCT inaturalist_id) AS inat_ids,
      ARRAY_AGG(DISTINCT inat_image) AS inat_images,
      ARRAY_AGG(DISTINCT wikidata_image) AS wikidata_images,
      to_tsvector('simple', canonical_name) ||
      to_tsvector('english', coalesce(common_names, '')) AS doc
      FROM ncbi_nodes
      LEFT JOIN external_resources
        ON external_resources.ncbi_id = ncbi_nodes.ncbi_id
        AND active = true
      LEFT JOIN ncbi_divisions
        ON ncbi_nodes.cal_division_id = ncbi_divisions.id
      GROUP BY ncbi_nodes.taxon_id, ncbi_divisions.name
      ORDER BY asvs_count DESC NULLS LAST
    ) AS search
    WHERE search.doc @@ plainto_tsquery('simple', $1)
    OR search.doc @@ plainto_tsquery('english', $1)
    LIMIT $2 OFFSET $3;
    SQL
  end

  def count_sql
    <<-SQL
    SELECT count(taxon_id)
    FROM (
      SELECT taxon_id,
      to_tsvector('simple', canonical_name) ||
      to_tsvector('english', coalesce(common_names, '')) as doc
      FROM ncbi_nodes
    ) AS search
    WHERE search.doc @@ plainto_tsquery('simple', #{conn.quote(query)})
    OR search.doc @@ plainto_tsquery('english', #{conn.quote(query)});
    SQL
  end

  def query
    params[:query]&.downcase
  end

  def limit
    12
  end
end
