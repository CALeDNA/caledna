# frozen_string_literal: true

namespace :inat do
  def conn
    ActiveRecord::Base.connection
  end

  task add_rank: :environment do
    def rank_sql(rank)
      <<~SQL
        UPDATE pour.inat_taxa set rank = $1
        WHERE #{rank} IS NOT NULL
        AND rank IS NULL
      SQL
    end

    rank = 'form'
    conn.exec_query(rank_sql(rank), 'q', [[nil, rank]])

    rank = 'variety'
    conn.exec_query(rank_sql(rank), 'q', [[nil, rank]])

    rank = 'subspecies'
    conn.exec_query(rank_sql(rank), 'q', [[nil, rank]])

    rank = 'species'
    conn.exec_query(rank_sql(rank), 'q', [[nil, rank]])

    rank = 'genus'
    conn.exec_query(rank_sql(rank), 'q', [[nil, rank]])

    rank = 'family'
    conn.exec_query(rank_sql(rank), 'q', [[nil, rank]])
  end

  task add_canonical_name: :environment do
    def create_sql(rank)
      <<~SQL
        UPDATE pour.inat_taxa
        SET canonical_name = #{rank}
        WHERE rank = $1;
      SQL
    end

    %i[kingdom phylum family genus species form subspecies
       variety].each do |rank|
      conn.exec_query(create_sql(rank), 'q', [[nil, rank]])
    end

    class_rank = '"class_name"'
    conn.exec_query(create_sql(class_rank), 'q', [[nil, 'class']])

    order_rank = '"order"'
    conn.exec_query(create_sql(order_rank), 'q', [[nil, 'order']])
  end

  task add_gbif_id: :environment do
    def gbif_id_sql(search_rank)
      <<~SQL
        UPDATE pour.inat_taxa SET gbif_id = temp.gbif_id FROM (
          SELECT inat_taxa.inat_id, gbif_taxa.taxon_id AS gbif_id
          FROM pour.inat_taxa
          JOIN pour.gbif_taxa
            ON gbif_taxa.canonical_name = inat_taxa.canonical_name
          WHERE inat_taxa.gbif_id IS NULL
          AND gbif_taxa.#{search_rank} = inat_taxa.#{search_rank}
          AND gbif_taxa.taxon_rank = inat_taxa.rank
        ) AS temp
        WHERE inat_taxa.inat_id = temp.inat_id
        AND inat_taxa.gbif_id IS NULL;
      SQL
    end
    %i[family order class_name phylum kingdom].each do |search_rank|
      conn.exec_query(gbif_id_sql(search_rank))
    end

    infra_sql = <<~SQL
      UPDATE pour.inat_taxa SET gbif_id = temp.gbif_id FROM (
        SELECT inat_taxa.inat_id, gbif_taxa.taxon_id AS gbif_id
        FROM pour.inat_taxa
        JOIN pour.gbif_taxa
          ON gbif_taxa.canonical_name = inat_taxa.canonical_name
        WHERE inat_taxa.gbif_id IS NULL
        AND gbif_taxa.taxon_rank IN ('subspecies', 'form', 'variety')
        AND inat_taxa.rank IN ('subspecies', 'form', 'variety')
      ) AS temp
      WHERE inat_taxa.inat_id = temp.inat_id
      AND inat_taxa.gbif_id IS NULL;
    SQL
    conn.exec_query(infra_sql)

    scientific_sql = <<~SQL
      UPDATE pour.inat_taxa SET gbif_id = temp.gbif_id FROM (
        SELECT inat_taxa.inat_id, gbif_taxa.taxon_id AS gbif_id
        FROM pour.inat_taxa
        JOIN pour.gbif_taxa
          ON gbif_taxa.scientific_name LIKE inat_taxa.canonical_name || '%'
        WHERE inat_taxa.gbif_id IS NULL
        AND gbif_taxa.taxon_rank = inat_taxa.rank
      ) AS temp
      WHERE inat_taxa.inat_id = temp.inat_id
      AND inat_taxa.gbif_id IS NULL;
    SQL
    conn.exec_query(scientific_sql)

    occurrence_sql = <<~SQL
      UPDATE pour.inat_taxa SET gbif_id = temp.gbif_id FROM (
        SELECT inat_taxa.inat_id , gbif_occurrences.taxon_id AS gbif_id
        FROM pour.inat_taxa
        JOIN pour.gbif_occurrences
          ON gbif_occurrences.verbatim_scientific_name = inat_taxa.canonical_name
        WHERE inat_taxa.gbif_id IS NULL
        AND gbif_occurrences.taxon_rank = inat_taxa.rank
      ) AS temp
      WHERE inat_taxa.inat_id = temp.inat_id
      AND inat_taxa.gbif_id IS NULL;
    SQL
    conn.exec_query(occurrence_sql)
  end

  task add_common_names_to_taxa: :environment do
    sql = <<~SQL
      UPDATE pour.gbif_taxa SET common_names = temp.common FROM (
        SELECT inat_taxa.common_name, gbif_taxa.taxon_id,
        gbif_taxa.common_names,
        CASE
          WHEN inat_taxa.common_name IS NULL
          AND gbif_taxa.common_names IS NOT NULL
            THEN gbif_taxa.common_names
          WHEN inat_taxa.common_name IS NOT NULL
          AND gbif_taxa.common_names IS NULL
            THEN inat_taxa.common_name
          WHEN inat_taxa.common_name = gbif_taxa.common_names
            THEN gbif_taxa.common_names
          ELSE inat_taxa.common_name || ' | ' || gbif_taxa.common_names
        END common
        FROM pour.inat_taxa
        JOIN pour.gbif_taxa ON gbif_taxa.taxon_id = inat_taxa.gbif_id
      ) AS temp
      WHERE gbif_taxa.taxon_id = temp.taxon_id;
    SQL
    conn.exec_query(sql)
  end
end
