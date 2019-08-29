# frozen_string_literal: true

class TaxaSearchesController < ApplicationController
  include CustomPagination

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
    raw_records = conn.exec_query(result_sql)
    records = raw_records.map { |r| OpenStruct.new(r) }
    add_pagination_methods(records)
    records
  end

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  def result_sql
    <<-SQL
    SELECT taxon_id, canonical_name, rank, alt_names, asvs_count,
    eol_ids, eol_images, eol_image_attributions,
    inat_ids, inat_images, inat_image_attributions,
    wikidata_images
    FROM (
      SELECT ncbi_nodes.taxon_id, ncbi_nodes.canonical_name, ncbi_nodes.rank,
      ncbi_nodes.alt_names, asvs_count,
      ARRAY_AGG(DISTINCT eol_id) AS eol_ids,
      ARRAY_AGG(DISTINCT eol_image) AS eol_images,
      ARRAY_AGG(DISTINCT eol_image_attribution) AS eol_image_attributions,
      ARRAY_AGG(DISTINCT inaturalist_id) AS inat_ids,
      ARRAY_AGG(DISTINCT inat_image) AS inat_images,
      ARRAY_AGG(DISTINCT inat_image_attribution) AS inat_image_attributions,
      ARRAY_AGG(DISTINCT wikidata_image) AS wikidata_images,
      to_tsvector('simple', canonical_name) ||
      to_tsvector('english', coalesce(alt_names, '')) AS doc
      FROM ncbi_nodes
      LEFT JOIN external_resources
      ON external_resources.ncbi_id = ncbi_nodes.taxon_id
      GROUP BY ncbi_nodes.taxon_id
      ORDER BY asvs_count DESC
    ) AS search
    WHERE search.doc @@ plainto_tsquery('simple', #{conn.quote(query)})
    OR search.doc @@ plainto_tsquery('english', #{conn.quote(query)})
    LIMIT #{limit} OFFSET #{offset};
    SQL
  end

  def count_sql
    <<-SQL
    SELECT count(taxon_id)
    FROM (
      SELECT taxon_id,
      to_tsvector('simple', canonical_name) ||
      to_tsvector('english', coalesce(alt_names, '')) as doc
      FROM ncbi_nodes
    ) AS search
    WHERE search.doc @@ plainto_tsquery('simple', #{conn.quote(query)})
    OR search.doc @@ plainto_tsquery('english', #{conn.quote(query)});
    SQL
  end

  def query
    params[:query].try(:downcase)
  end

  def limit
    10
  end
end
