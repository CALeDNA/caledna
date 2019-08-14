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

  private

  def conn
    @conn ||= ActiveRecord::Base.connection
  end
end
