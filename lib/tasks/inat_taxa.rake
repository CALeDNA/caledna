# frozen_string_literal: true

namespace :inat_taxa do
  require_relative '../../app/services/import_csv/inat_observations'
  require_relative '../../app/services/inat_api.rb'
  include ImportCsv::InatObservations

  def api
    ::InatApi.new
  end

  # bin/rake inat_obs:create_la_river_inat_taxa[<path>]
  task :create_la_river_inat_taxa, [:path] => :environment do |_t, args|
    path = args[:path]
    puts 'import inat ...'

    import_taxa_csv(path)
  end

  task update_existing_taxa: :environment do
    InatTaxon.where("ids = '{}'").each do |taxon|
      sleep(0.5)
      name = taxon.canonical_name
      rank = taxon.rank

      api.get_taxa(name: name, rank: rank) do |results|
        record = results.select do |item|
          item['name'] == name && item['rank'] == rank
        end.first

        next if record.blank?

        attributes = {
          photo: record['default_photo'],
          wikipedia_url: record['wikipedia_url'],
          ids: record['ancestor_ids'],
          iconic_taxon_name: record['iconic_taxon_name'],
          common_name: record['preferred_common_name']
        }

        if taxon.rank != 'species'
          attributes = attributes.merge(taxon_id: record['id'])
        end

        taxon.update(attributes)
      end
    end
  end

  task create_higher_ranks: :environment do
    rank_data = [
      {
        field: 'genus',
        rank: 'genus',
        child_rank: 'species',
        sql: 'DISTINCT kingdom, phylum, class_name, "order", family, genus'
      },
      {
        field: 'family',
        rank: 'family',
        child_rank: 'genus',
        sql: 'DISTINCT kingdom, phylum, class_name, "order", family'
      },
      {
        field: '"order"',
        rank: 'order',
        child_rank: 'family',
        sql: 'DISTINCT kingdom, phylum, class_name, "order"'
      },
      {
        field: 'class_name',
        rank: 'class',
        child_rank: 'order',
        sql: 'DISTINCT kingdom, phylum, class_name'
      },
      {
        field: 'phylum',
        rank: 'phylum',
        child_rank: 'class',
        sql: 'DISTINCT kingdom, phylum'
      },
      {
        field: 'kingdom',
        rank: 'kingdom',
        child_rank: 'phylum',
        sql: 'DISTINCT kingdom'
      }
    ]

    rank_data.each do |record|
      taxa = InatTaxon.where(rank: record[:child_rank])
                      .where("#{record[:field]} IS NOT NULL")
                      .select(record[:sql])

      taxa.each do |taxon|
        puts record[:field]

        attributes = taxon.attributes.merge(
          rank: record[:rank],
          id: rand(1_000_000..2_000_000),
          canonical_name: taxon.send(record[:field].tr('"', ''))
        )
        InatTaxon.create(attributes)
      end
    end
  end

  task add_source: :environment do
    sql = <<-SQL
      UPDATE external.inat_taxa
      SET source = 'iNaturalist Observation'
      where rank = 'species';
    SQL
    conn.exec_query(sql)

    sql = <<-SQL
      UPDATE external.inat_taxa
      SET source = 'generated higher taxa'
      where rank != 'species';
    SQL
    conn.exec_query(sql)
  end

  # step 5: add inat_id to higher ncbi taxa
  desc 'create inat taxa for the inat ids generated in exteral_resources'
  task create_inat_taxa_for_ncbi_higher_ranks: :environment do
    sql = <<-SQL
    SELECT inaturalist_id
    FROM external_resources
    JOIN ncbi_nodes
      ON ncbi_nodes.taxon_id = external_resources.ncbi_id
    WHERE ncbi_nodes.rank
      IN ('superkingdom', 'kingdom', 'phylum', 'class', 'order')
    AND (
      (ncbi_nodes.hierarchy_names ->> 'superkingdom')::Text = 'Eukaryota'
    )
    AND inaturalist_id NOT IN (SELECT taxon_id FROM external.inat_taxa)
    AND inaturalist_id IS NOT NULL;
    SQL
    resources = conn.exec_query(sql)

    resources.each do |resource|
      sleep(1.5)
      inat_taxa = resource['inaturalist_id']

      api.get_taxon(inat_taxa) do |result|
        record = result.first
        puts "#{record['id']}: #{record['name']}"

        attributes = format_inat_taxon_attributes(record, inat_taxa)
        InatTaxon.create(attributes)
      end
    end
  end

  # step 6: add inat_id to higher ncbi taxa
  desc 'create taxa for all the ids that dont have inat taxa records'
  task create_inat_taxa_for_ids: :environment do
    sql = <<-SQL
    SELECT (unnest(ids))::BIGINT as inaturalist_id
    FROM external.inat_taxa
    EXCEPT
    SELECT taxon_id
    FROM external.inat_taxa;
    SQL
    resources = conn.exec_query(sql)

    resources.each do |resource|
      sleep(1.5)
      inat_taxa = resource['inaturalist_id']

      api.get_taxon(inat_taxa) do |result|
        record = result.first
        puts "#{record['id']}: #{record['name']}"

        attributes = format_inat_taxon_attributes(record, inat_taxa)
        InatTaxon.create(attributes)
      end
    end
  end

  private

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  def create_taxonomy_hierarchy(ancestors, rank, name)
    hierarchy = {}
    return hierarchy if ancestors.blank?

    ancestors.each do |ancestor|
      hierarchy[ancestor['rank']] = ancestor['name']
    end
    hierarchy[rank] = name

    hierarchy
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def format_inat_taxon_attributes(record, inat_id)
    hierarchy = create_taxonomy_hierarchy(
      record['ancestors'], record['rank'], record['name']
    )

    {
      taxon_id: inat_id,
      photo: record['default_photo'],
      wikipedia_url: record['wikipedia_url'],
      ids: record['ancestor_ids'] << record['id'],
      iconic_taxon_name: record['iconic_taxon_name'],
      common_name: record['preferred_common_name'],
      canonical_name: record['name'],
      rank: record['rank'],
      kingdom: hierarchy['kingdom'],
      phylum: hierarchy['phylum'],
      class_name: hierarchy['class'],
      order: hierarchy['order'],
      family: hierarchy['family'],
      genus: hierarchy['genus'],
      species: hierarchy['species'],
      source: 'ncbi higher ranks'
    }
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
