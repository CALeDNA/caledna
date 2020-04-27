# frozen_string_literal: true

namespace :misc do
  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  desc '1. remove old taxa tree data for BOLD taxa'
  task reset_bold_taxa: :environment do
    sql = <<-SQL
      UPDATE ncbi_nodes
      SET parent_taxon_id = NULL, division_id = NULL, cal_division_id = NULL,
        full_taxonomy_string = NULL,
        ids = '{}', ranks = '{}', names = '{}',
        hierarchy_names = '{}',  hierarchy = '{}'
      WHERE( bold_id IS NOT NULL)
      AND ( ncbi_id IS NULL);
    SQL

    conn.exec_query(sql)
  end

  desc '2. add taxa tree data for BOLD species'
  task update_bold_taxa_tree: :environment do
    sql = <<-SQL
      SELECT result_taxa.taxon_id, result_taxa.taxon_rank,
        result_taxa.canonical_name,
        parent.ncbi_id AS parent_taxon_id
      FROM result_taxa
      JOIN ncbi_nodes AS parent ON LOWER(parent.canonical_name) =
        LOWER(result_taxa.hierarchy ->> 'genus')
      WHERE (result_taxa.bold_id IS NOT NULL)
      AND (result_taxa.ncbi_id IS NULL)
      AND result_taxa.taxon_rank = 'species'
      AND parent.rank = 'genus'
      AND parent.source = 'NCBI'
      AND result_taxa.hierarchy ->> 'family' =
        parent.hierarchy_names ->> 'family'
      ;
    SQL

    res = conn.exec_query(sql)
    res.entries.each do |record|
      puts record['canonical_name']

      parent_taxon = NcbiNode.find(record['parent_taxon_id'])
      taxon = NcbiNode.find(record['taxon_id'])

      parent_taxon.ids << record['taxon_id']
      taxon.ids = parent_taxon.ids

      parent_taxon.names << record['canonical_name']
      taxon.names = parent_taxon.names

      parent_taxon.ranks << record['taxon_rank']
      taxon.ranks = parent_taxon.ranks

      taxon.hierarchy =
        parent_taxon.hierarchy
                    .merge(record['taxon_rank'] => record['taxon_id'])

      taxon.hierarchy_names =
        parent_taxon.hierarchy_names
                    .merge(record['taxon_rank'] => record['canonical_name'])

      taxon.full_taxonomy_string =
        parent_taxon.full_taxonomy_string + "|#{record['canonical_name']}"

      taxon.parent_taxon_id = record['parent_taxon_id']

      taxon.division_id = parent_taxon.division_id
      taxon.cal_division_id = parent_taxon.cal_division_id

      taxon.save
    end
  end

  desc '3 mark BOLD ResultTaxon as not normalized'
  task mark_bold_not_normalized: :environment do
    sql = <<-SQL
      UPDATE result_taxa
      SET  normalized = false
      WHERE id IN (
        SELECT id FROM result_taxa
        JOIN ncbi_nodes ON ncbi_nodes.taxon_id = result_taxa.taxon_id
        WHERE (result_taxa.bold_id IS NOT NULL)
        AND (result_taxa.ncbi_id IS NULL)
        AND ncbi_nodes.full_taxonomy_string IS NULL
      );
    SQL

    conn.exec_query(sql)
  end
end
