# frozen_string_literal: true

namespace :gbif do
  desc 'Pillar Point GBIF'
  task import_missing_fields_for_pp_occ_taxa: :environment do
    api = GbifApi.new
    conn = ActiveRecord::Base.connection

    PpGbifOccTaxa.where(taxonkey: nil).each do |taxon|
      rank = taxon.taxonrank
      query = { rank: taxon.taxonrank }
      if rank == 'kingdom'
        query[:kingdom] = taxon.kingdom
        rank_sql = "AND kingdom = #{conn.quote(taxon.kingdom)}"
      elsif rank == 'phylum'
        query[:phylum] = taxon.phylum
        rank_sql = "AND phylum = #{conn.quote(taxon.phylum)}"
      elsif rank == 'class'
        query[:class] = taxon.classname
        rank_sql = "AND classname = #{conn.quote(taxon.classname)}"
      elsif rank == 'order'
        query[:order] = taxon.order
        rank_sql = "AND \"order\" = #{conn.quote(taxon.order)}"
      elsif rank == 'family'
        query[:family] = taxon.family
        rank_sql = "AND family = #{conn.quote(taxon.family)}"
      elsif rank == 'genus'
        query[:family] = taxon.family
        query[:genus] = taxon.genus
        rank_sql = "AND family = #{conn.quote(taxon.family)} " \
          "AND genus = #{conn.quote(taxon.genus)}"
      else
        next
      end

      response = api.taxa_by_rank(query)
      result = response.parsed_response

      puts result['usageKey']

      taxon.taxonkey = result['usageKey']
      taxon.scientificname = result['scientificName']
      sql = 'UPDATE pillar_point.gbif_occ_taxa ' \
      "SET taxonkey = #{result['usageKey']},  " \
      "scientificname = #{conn.quote(result['scientificName'])} " \
      "WHERE taxonrank = #{conn.quote(rank)} " \
      'AND taxonkey IS NULL '
      sql += rank_sql

      conn.execute(sql)
    end
  end

  desc 'PouR GBIF'
  # https://stackoverflow.com/a/29502094
  # bin/rake gbif:import_gbif_taxa'[/full/path]'
  task :import_gbif_taxa, [:path] => :environment do |_t, args|
    include CsvUtils

    path = args[:path]
    if path.blank?
      puts 'Must pass in path for taxa csv'
      next
    end

    puts 'importing taxa...'

    delim = delimiter_detector(OpenStruct.new(path: path))
    CSV.foreach(path, headers: true, col_sep: delim) do |row|
      attributes = {
        taxon_id: row['taxonKey'],
        scientific_name: row['scientificName'],
        accepted_taxon_id: row['acceptedTaxonKey'],
        accepted_scientific_name: row['acceptedScientificName'],
        taxon_rank: row['taxonRank'].downcase,
        taxonomic_status: row['taxonomicStatus'].downcase,
        kingdom: row['kingdom'],
        kingdom_id: row['kingdomKey'],
        phylum: row['phylum'],
        phylum_id: row['phylumKey'],
        class_name: row['class'],
        class_id: row['classKey'],
        order: row['order'],
        order_id: row['orderKey'],
        family: row['family'],
        family_id: row['familyKey'],
        genus: row['genus'],
        genus_id: row['genusKey'],
        species: row['species'],
        species_id: row['speciesKey']
      }
      PourGbifTaxon.create(attributes)
    end
  end

  task :import_gbif_occurrences, [:path] => :environment do |_t, args|
    include CsvUtils

    path = args[:path]
    if path.blank?
      puts 'Must pass in path for occurences csv'
      next
    end

    puts 'importing occurences...'

    delim = delimiter_detector(OpenStruct.new(path: path))
    def convert_date(field)
      return if field.blank?
      DateTime.parse(field)
    end

    datasets = {}

    PourGbifDataset.all.each do |dataset|
      datasets[dataset.dataset_key] = dataset.id
    end

    # https://stackoverflow.com/a/59353901
    # NOTE: using √ as quote_char because reader errors out if values has "
    CSV.foreach(path, headers: true, col_sep: delim,
                      encoding: 'bom|utf-8', quote_char: '√') do |row|
      attributes = {
        gbif_id: row['gbifID'],
        gbif_dataset_id: datasets[row['datasetKey']],
        occurrence_id: row['occurrenceID'],
        taxon_rank: row['taxonRank'].downcase,
        infraspecific_epithet: row['infraspecificEpithet'],
        scientific_name: row['scientificName'],
        verbatim_scientific_name: row['verbatimScientificName'],
        verbatim_scientific_name_authorship:
          row['verbatimScientificNameAuthorship'],
        country_code: row['countryCode'],
        locality: row['locality'],
        occurrence_status: row['occurrenceStatus'],
        individual_count: row['individualCount'],
        publishing_org_key: row['publishingOrgKey'],
        state_province: row['stateProvince'],
        latitude: row['decimalLatitude'],
        longitude: row['decimalLongitude'],
        coordinate_uncertainty_in_meters: row['coordinateUncertaintyInMeters'],
        coordinate_precision: row['coordinatePrecision'],
        elevation: row['elevation'],
        elevation_accuracy: row['elevationAccuracy'],
        depth: row['depth'],
        depth_accuracy: row['depthAccuracy'],
        day: row['day'],
        month: row['month'],
        year: row['year'],
        geom: "POINT(#{row['decimalLongitude']} #{row['decimalLatitude']})",
        taxon_id: row['taxonKey'],
        basis_of_record: row['basisOfRecord'],
        catalog_number: row['catalogNumber'],
        institution_code: row['institutionCode'],
        collection_code: row['collectionCode'],
        record_number: row['recordNumber'],
        identified_by: row['identifiedBy'],
        license: row['license'],
        rights_holder: row['rightsHolder'],
        recorded_by: row['recordedBy'],
        type_status: row['typeStatus'],
        establishment_means: row['establishmentMeans'],
        media_type: row['mediaType'],
        issue: row['issue'],
        event_date: convert_date(row['eventDate']),
        date_identified: convert_date(row['dateIdentified']),
        last_interpreted: convert_date(row['lastInterpreted'])
      }

      PourGbifOccurrence.create(attributes)
    end
  end

  task add_missing_taxon: :environment do
    kingdom_sql = <<~SQL
      select  kingdom, kingdom_id,
      'kingdom' as taxon_rank, kingdom as scientific_name,
      kingdom_id as taxon_id,
      array[kingdom] as names
      from pour.gbif_taxa
      group by kingdom, kingdom_id;
    SQL

    phylum_sql = <<~SQL
      select  kingdom, kingdom_id,
      phylum, phylum_id,
      'phylum' as taxon_rank, phylum as scientific_name,
      phylum_id as taxon_id,
      array[kingdom, phylum] as names
      from pour.gbif_taxa
      where phylum is not null
      group by kingdom, kingdom_id, phylum, phylum_id;
    SQL

    class_sql = <<~SQL
      select kingdom, kingdom_id,
      phylum, phylum_id,
      class_name, class_id ,
      'class' as taxon_rank, class_name as scientific_name,
      class_id as taxon_id,
      array[kingdom, phylum, class_name] as names
      from pour.gbif_taxa
      where class_name is not null
      group by kingdom, kingdom_id, phylum, phylum_id, class_name, class_id;
    SQL

    order_sql = <<~SQL
      select kingdom, kingdom_id,
      phylum, phylum_id,
      class_name, class_id,
      "order", order_id ,
      'order' as taxon_rank, "order" as scientific_name,
      order_id as taxon_id,
      array[kingdom, phylum, class_name, "order"] as names
      from pour.gbif_taxa
      where "order" is not null
      group by kingdom, kingdom_id, phylum, phylum_id, class_name, class_id,
      "order", order_id;
    SQL

    family_sql = <<~SQL
      select kingdom, kingdom_id,
      phylum, phylum_id,
      class_name, class_id,
      "order", order_id ,
      family, family_id,
      'family' as taxon_rank, family as scientific_name,
      family_id as taxon_id,
      array[kingdom, phylum, class_name, "order", family] as names
      from pour.gbif_taxa
      where family is not null
      group by kingdom, kingdom_id, phylum, phylum_id, class_name, class_id,
      "order", order_id, family, family_id;
    SQL

    genus_sql = <<~SQL
      select  kingdom, kingdom_id,
      phylum, phylum_id,
      class_name, class_id,
      "order", order_id ,
      family, family_id,
      genus, genus_id,
      'genus' as taxon_rank, genus as scientific_name,
      genus_id as taxon_id,
      array[kingdom, phylum, class_name, "order", family, genus] as names
      from pour.gbif_taxa
      where genus is not null
      group by kingdom, kingdom_id, phylum, phylum_id, class_name, class_id,
      "order", order_id, family, family_id, genus, genus_id;
    SQL

    [kingdom_sql, phylum_sql, class_sql, order_sql, family_sql,
     genus_sql].each do |sql|
      results = conn.exec_query(sql)
      results.each do |res|
        taxon = PourGbifTaxon.find_by(taxon_id: res['taxon_id'])
        next if taxon.present?
        PourGbifTaxon.create(res)
      end
    end
  end

  task add_infraspecies_to_taxa: :environment do
    sql = <<~SQL
      UPDATE pour.gbif_taxa
      SET infraspecific_epithet = temp.infraspecific_epithet FROM (
        SELECT infraspecific_epithet, taxon_id
        FROM pour.gbif_occurrences
        GROUP BY infraspecific_epithet, taxon_id
      ) AS temp
      WHERE gbif_taxa.taxon_id = temp.taxon_id;
    SQL

    conn.exec_query(sql)
  end

  task add_canonical_name: :environment do
    def create_sql(rank)
      <<~SQL
        UPDATE pour.gbif_taxa
        SET canonical_name = #{rank}
        WHERE taxon_rank = $1;
      SQL
    end

    %i[kingdom phylum family genus species].each do |rank|
      conn.exec_query(create_sql(rank), 'q', [[nil, rank]])
    end

    class_rank = '"class_name"'
    conn.exec_query(create_sql(class_rank), 'q', [[nil, 'class']])

    order_rank = '"order"'
    conn.exec_query(create_sql(order_rank), 'q', [[nil, 'order']])

    %i[form subspecies variety].each do |rank|
      infra_rank = "species || ' ' || infraspecific_epithet"
      conn.exec_query(create_sql(infra_rank), 'q', [[nil, rank]])
    end
  end

  task add_names_to_taxa: :environment do
    PourGbifTaxon.find_each do |taxon|
      puts taxon.taxon_id

      all_names = [taxon.kingdom, taxon.phylum, taxon.class_name, taxon.order,
                   taxon.family, taxon.genus, taxon.species].compact

      if taxon.infraspecific_epithet
        all_names << "#{taxon.species} #{taxon.infraspecific_epithet}"
      end

      taxon.names = all_names
      taxon.save
    end
  end

  task add_ids_to_taxa: :environment do
    PourGbifTaxon.find_each do |taxon|
      puts taxon.taxon_id

      all_ids = [taxon.kingdom_id, taxon.phylum_id, taxon.class_id,
                 taxon.order_id, taxon.family_id, taxon.genus_id,
                 taxon.species_id].compact

      all_ids << taxon.taxon_id unless all_ids.include?(taxon.taxon_id)

      taxon.ids = all_ids
      taxon.save
    end
  end

  task add_common_names_to_taxa: :environment do
    sql = <<~SQL
      UPDATE pour.gbif_taxa
      SET common_names =
        coalesce(common_names || ' | ' || temp.vernacular_name, common_names)
      FROM (
        SELECT vernacular_name, taxon_id
        FROM pour.gbif_common_names
      ) AS temp
      WHERE gbif_taxa.taxon_id = temp.taxon_id
    SQL

    conn.exec_query(sql)
  end

  task update_occurrence_count: :environment do
    sql = <<~SQL
      SELECT UNNEST(ids) as id, count(*)
      FROM pour.gbif_taxa
      JOIN pour.gbif_occurrences
      ON gbif_occurrences.taxon_id = gbif_taxa.taxon_id
      GROUP BY UNNEST(ids);
    SQL

    results = conn.exec_query(sql)
    results.each do |res|
      sql =
        'UPDATE pour.gbif_taxa SET occurrence_count = $1 WHERE taxon_id = $2'
      bindings = [[nil, res['count']], [nil, res['id']]]
      conn.exec_query(sql, 'q', bindings)
    end
  end

  desc 'external tos GBIF'

  task add_missing_taxon_tos: :environment do
    kingdom_sql = <<~SQL
      select  kingdom, kingdom_id,
      'kingdom' as taxon_rank, kingdom as canonical_name,
      kingdom_id as taxon_id
      from external.gbif_taxa_tos
      group by kingdom, kingdom_id;
    SQL

    phylum_sql = <<~SQL
      select  kingdom, kingdom_id,
      phylum, phylum_id,
      'phylum' as taxon_rank, phylum as canonical_name,
      phylum_id as taxon_id
      from external.gbif_taxa_tos
      where phylum is not null
      group by kingdom, kingdom_id, phylum, phylum_id;
    SQL

    class_sql = <<~SQL
      select kingdom, kingdom_id,
      phylum, phylum_id,
      class_name, class_id ,
      'class' as taxon_rank, class_name as canonical_name,
      class_id as taxon_id
      from external.gbif_taxa_tos
      where class_name is not null
      group by kingdom, kingdom_id, phylum, phylum_id, class_name, class_id;
    SQL

    order_sql = <<~SQL
      select kingdom, kingdom_id,
      phylum, phylum_id,
      class_name, class_id,
      "order", order_id ,
      'order' as taxon_rank, "order" as canonical_name,
      order_id as taxon_id
      from external.gbif_taxa_tos
      where "order" is not null
      group by kingdom, kingdom_id, phylum, phylum_id, class_name, class_id,
      "order", order_id;
    SQL

    family_sql = <<~SQL
      select kingdom, kingdom_id,
      phylum, phylum_id,
      class_name, class_id,
      "order", order_id ,
      family, family_id,
      'family' as taxon_rank, family as canonical_name,
      family_id as taxon_id
      from external.gbif_taxa_tos
      where family is not null
      group by kingdom, kingdom_id, phylum, phylum_id, class_name, class_id,
      "order", order_id, family, family_id;
    SQL

    genus_sql = <<~SQL
      select  kingdom, kingdom_id,
      phylum, phylum_id,
      class_name, class_id,
      "order", order_id ,
      family, family_id,
      genus, genus_id,
      'genus' as taxon_rank, genus as canonical_name,
      genus_id as taxon_id
      from external.gbif_taxa_tos
      where genus is not null
      group by kingdom, kingdom_id, phylum, phylum_id, class_name, class_id,
      "order", order_id, family, family_id, genus, genus_id;
    SQL

    [kingdom_sql, phylum_sql, class_sql, order_sql, family_sql,
     genus_sql].each do |sql|
      results = conn.exec_query(sql)
      results.each do |res|
        next if res['taxon_id'].blank?
        taxon = GbifTaxonTos.find_by(taxon_id: res['taxon_id'])
        next if taxon.present?

        GbifTaxonTos.create(res)
      end
    end
  end

  task add_canonical_name_tos: :environment do
    def create_sql(rank)
      <<~SQL
        UPDATE external.gbif_taxa_tos
        SET canonical_name = #{rank}
        WHERE taxon_rank = $1
        AND canonical_name is NULL;
      SQL
    end

    %i[kingdom phylum family genus species].each do |rank|
      conn.exec_query(create_sql(rank), 'q', [[nil, rank]])
    end

    class_rank = '"class_name"'
    conn.exec_query(create_sql(class_rank), 'q', [[nil, 'class']])

    order_rank = '"order"'
    conn.exec_query(create_sql(order_rank), 'q', [[nil, 'order']])

    %i[form subspecies variety].each do |rank|
      infra_rank = 'accepted_scientific_name'
      conn.exec_query(create_sql(infra_rank), 'q', [[nil, rank]])
    end

    GbifTaxonTos.where(canonical_name: nil).find_each do |taxon|
      names = [taxon.species, taxon.genus, taxon.family, taxon.order,
               taxon.class_name, taxon.phylum, taxon.kingdom].compact
      taxon.canonical_name = names.first
      taxon.save
    end
  end

  def conn
    ActiveRecord::Base.connection
  end
end
