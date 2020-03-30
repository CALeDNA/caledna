# frozen_string_literal: true

namespace :combine_taxa do
  require 'csv'
  require_relative '../../app/services/import_combine_taxa'
  include ImportCombineTaxa

  desc 'import taxa from Ruggiero paper csv'
  task import_research_paper: :environment do
    path =  ENV['file']

    ranks = %w[
      superkingdom kingdom subkingdom infrakingdom superphylum phylum subphylum
      infraphylum superclass class subclass infraclass superorder order
    ]
    taxa_data = {}
    taxa_history = {}
    column_with_taxon_index = 0

    ranks.each do |rank|
      taxa_history[rank] = nil
    end

    CSV.foreach(path, headers: true, col_sep: ',') do |row|
      puts row

      ranks.each.with_index do |rank, index|
        if row[rank].present?
          taxa_data = parse_taxon(row[rank])
          next if taxa_data.blank?

          name = taxa_data[:name]
          next if name.blank?

          taxa_history[rank] = name

          if column_with_taxon_index > index
            [*(index + 1)..ranks.length].each do |num|
              taxa_history[ranks[num]] = nil
            end
          end
          column_with_taxon_index = index
        end
      end

      next if taxa_data.blank?

      hierarchy_names = taxa_history.reject { |_k, v| v.blank? }
      full_taxonomy_string = taxa_history.values.join(';')

      attributes = {
        source: 'paper',
        notes: taxa_data[:notes],
        full_taxonomy_string: full_taxonomy_string
      }

      if taxa_data[:name].present?
        attributes.merge!(
          superkingdom: taxa_history['superkingdom'],
          kingdom: taxa_history['kingdom'],
          phylum: taxa_history['phylum'],
          class_name: taxa_history['class'],
          order: taxa_history['order'],
          family: taxa_history['family'],
          genus: taxa_history['genus'],
          species: taxa_history['species'],
          synonym: taxa_data[:synonym],
          taxon_rank: taxa_data[:rank],
          hierarchy_names: hierarchy_names,
          short_taxonomy_string:
            create_combine_taxa_taxonomy_string(taxa_history)
        )
      end

      CombineTaxon.create(attributes)
    end
  end

  desc 'use this sql to create unique taxa csv in Postico'
  task create_unique_found_taxa: :environment do
    project
    <<-SQL
      SELECT
      'gbif' AS source, taxonkey AS taxon_id, NULL AS cal_division_id,
      NULL AS superkingdom, kingdom, phylum,
      classname AS class, "order", family, genus, species,
      lower(taxonrank) AS taxon_rank
      FROM external.gbif_occurrences
      JOIN research_project_sources
      ON external.gbif_occurrences.gbifid =
      research_project_sources.sourceable_id
      AND research_project_id = 4
      AND sourceable_type = 'GbifOccurrence'
      AND metadata ->> 'location' != 'Montara SMR'
      WHERE kingdom IS NOT NULL

      UNION

      SELECT
      'ncbi' AS source, taxon_id,
      cal_division_id,
      hierarchy_names ->> 'superkingdom' AS superkingdom ,
      hierarchy_names ->> 'kingdom' AS kingdom ,
      hierarchy_names ->> 'phylum' AS phylum ,
      hierarchy_names ->> 'class' AS class,
      hierarchy_names ->> 'order'  AS order,
      hierarchy_names ->> 'family' AS family,
      hierarchy_names ->> 'genus' AS genus,
      hierarchy_names ->> 'species' AS species,
      rank AS taxon_rank
      FROM asvs
      JOIN research_project_sources
      ON asvs.sample_id = research_project_sources.sourceable_id
      AND research_project_id = 4
      AND sourceable_type = 'Sample'
      JOIN ncbi_nodes
      ON ncbi_nodes.taxon_id = asvs.taxon_id
      ORDER BY superkingdom, kingdom, phylum,
      class,  "order",  family,  genus, species;
    SQL
  end

  #  bin/rake combine_taxa:import_unique_found_taxa file=xxx
  desc 'import eDNA and gbif unique taxa from Pillar Point'
  task import_unique_found_taxa: :environment do
    path = ENV['file']

    CSV.foreach(path, headers: true) do |row|
      taxon =
        CombineTaxon.where(taxon_id: row['taxon_id'], source: row['source'])
      next if taxon.present?

      row.to_h.each { |k, v| row[k] = v&.strip }

      if row['source'] == 'ncbi' || row['source'] == 'gbif'
        CombineTaxon.create(
          source: row['source'],
          taxon_id: row['taxon_id'],
          source_superkingdom: row['superkingdom'],
          source_kingdom: row['kingdom'],
          source_phylum: row['phylum'],
          source_class_name: row['class'],
          source_order: row['order'],
          source_family: row['family'],
          source_genus: row['genus'],
          source_species: row['species'],
          cal_division_id: row['cal_division_id'],
          taxon_rank: row['taxon_rank']
        )
      end
    end
  end

  desc 'update taxa occurrences that have exact order match with Ruggerio paper'
  task update_occurence_taxa_exact_order_match: :environment do
    sql = <<-SQL
      UPDATE  combine_taxa AS source
      SET
      superkingdom = paper.superkingdom,
      kingdom = paper.kingdom,
      phylum  = paper.phylum,
      class_name = paper.class_name,
      "order" = paper.order,
      family = source.source_family,
      genus = source.source_genus,
      species = source.source_species,
      paper_match_type = 'exact_order'
      FROM combine_taxa AS paper
      WHERE paper."order" = source.source_order
      AND paper.source = 'paper'
      AND (source.source = 'gbif' OR source.source = 'ncbi');
    SQL

    ActiveRecord::Base.connection.exec_query(sql)
  end

  desc 'create csv of taxa that do not have order match with Ruggerio paper'
  task update_occurence_taxa_manual_order: :environment do
    include ImportGlobalNames

    output_file = 'data/combine_taxa/manual_order.csv'

    CSV.open(output_file, 'a+') do |csv|
      csv << %w[
        id source source_kingdom source_phylum source_class_name
        source_order source_family source_genus order gbif ncbi irmng
        worms opol fungorum notes
      ]
    end

    taxa = CombineTaxon.where('paper_match_type is null')
                       .where("(source = 'gbif' or source = 'ncbi')")
                       .where('source_order is not null')
                       .order(:id)

    puts "records count: #{taxa.count} ======"

    taxon_history = {}

    taxa.each do |taxon|
      source_family = taxon.source_family
      source_genus = taxon.source_genus
      taxon_history_key = source_family || source_genus

      gn = if taxon_history[taxon_history_key].present?
             puts "cached: #{taxon_history_key}"
             taxon_history[taxon_history_key]
           elsif source_family.present?
             puts source_family
             taxon_history[source_family] = fetch_global_names(source_family)
           elsif source_genus.present?
             puts source_genus
             taxon_history[source_genus] = fetch_global_names(source_genus)
           else
             {}
           end

      CSV.open(output_file, 'a+') do |csv|
        csv << [
          taxon.id,
          taxon.source,
          taxon.source_kingdom,
          taxon.source_phylum,
          taxon.source_class_name,
          taxon.source_order,
          source_family,
          taxon.source_genus,
          '',
          gn[:gbif],
          gn[:ncbi],
          gn[:irmng],
          gn[:worms],
          gn[:opol],
          gn[:fungorum],
          taxon.notes
        ]
      end
    end
  end

  desc 'import csv of taxa that have manually added orders from Ruggerio paper'
  task import_manual_orders: :environment do
    path = ENV['file']

    CSV.foreach(path, headers: true, col_sep: ',') do |row|
      taxa = CombineTaxon.find(row['id'])

      if row['order'].present?
        taxa.update(
          order: row['order'],
          global_names: {
            gbif: row['gbif'],
            ncbi: row['ncbi'],
            irmng: row['irmng'],
            worms: row['worms'],
            opol: row['opol']
          },
          paper_match_type: 'manually update order'
        )
      else
        taxa.update(
          global_names: {
            gbif: row['gbif'],
            ncbi: row['ncbi'],
            irmng: row['irmng'],
            worms: row['worms'],
            opol: row['opol']
          },
          paper_match_type: 'manually update order'
        )
      end
    end

    sql = <<-SQL
    UPDATE  combine_taxa AS source
    SET
    superkingdom = paper.superkingdom,
    kingdom = paper.kingdom,
    phylum  = paper.phylum,
    class_name = paper.class_name,
    "order" = paper.order,
    family = source.source_family,
    genus = source.source_genus,
    species = source.source_species
    FROM combine_taxa AS paper
    WHERE paper."order" = source.order
    AND paper.source = 'paper'
    AND source.paper_match_type = 'manually update order'
    SQL

    ActiveRecord::Base.connection.exec_query(sql)
  end

  #  bin/rake combine_taxa:export_asv_results file=data/edna/xxx
  task export_asv_results: :environment do
    path = ENV['file']
    parts = path.split('/')
    file_name = parts.last
    parts.pop

    output_file = "#{parts.join('/')}/converted_#{file_name}"

    append_header(path, output_file)

    CSV.foreach(path, headers: true, col_sep: "\t") do |row|
      result_taxon = find_result_taxon(row['sum.taxonomy'])
      puts result_taxon&.taxon_id || row['sum.taxonomy']

      if result_taxon.present?
        taxon = NcbiNode.find(result_taxon.taxon_id)
        taxon_id = taxon.ncbi_id || taxon.bold_id
        source = taxon.ncbi_id.present? ? 'ncbi' : 'bold'
      end

      CSV.open(output_file, 'a+') do |csv|
        if result_taxon.present?
          combine_taxon =
            CombineTaxon.where(caledna_taxon_id: result_taxon.taxon_id)
                        .where("source ='ncbi' or source='bold'")
                        .first

          # rubocop:disable Style/ConditionalAssignment
          if combine_taxon.present?
            csv << [source, taxon_id, combine_taxon.short_taxonomy_string] +
                   row.to_h.values
          else
            csv << ['', '', "no Ruggerio conversion #{result_taxon.taxon_id}"] +
                   row.to_h.values
          end
          # rubocop:enable Style/ConditionalAssignment
        else
          csv << ['', '', 'no sum.taxonomy match'] + row.to_h.values
        end
      end
    end
  end

  desc 'import Rachel approved csv of manually added orders from Ruggerio paper'
  task import_finalized_manual_orders: :environment do
    path = ENV['file']

    CSV.foreach(path, headers: true, col_sep: ',') do |row|
      taxa = CombineTaxon.where(
        source: row['source'], source_taxon_id: row['taxon_id']
      )
      puts "#{row['taxon_id']}, #{row['source']}"
      raise if taxa.blank?
      raise if taxa.length > 1

      taxon = taxa.first

      taxon.update(
        superkingdom: row['superkingdom_v2'],
        kingdom: row['kingdom_v2'],
        phylum: row['phylum_v2'],
        class_name: row['class_v2'],
        order: row['order_v2'],
        family: row['family_v2'],
        genus: row['genus_v2'],
        species: row['species_v2'],
        paper_match_type: 'manually update',
        approved: true
      )
    end
  end

  task update_bold_id: :environment do
    combine_taxa = CombineTaxon.where(source: 'bold')
    combine_taxa.each do |combine_taxon|
      ncbi = NcbiNode.find_by(taxon_id: combine_taxon.caledna_taxon_id)
      combine_taxon.update(source_taxon_id: ncbi.bold_id)
    end
  end

  task update_taxon_rank: :environment do
    sql = <<-SQL
      UPDATE combine_taxa SET taxon_rank = 'superkingdom' WHERE superkingdom IS NOT NULL;
      UPDATE combine_taxa SET taxon_rank = 'kingdom' WHERE kingdom IS NOT NULL;
      UPDATE combine_taxa SET taxon_rank = 'phylum' WHERE phylum IS NOT NULL;
      UPDATE combine_taxa SET taxon_rank = 'class' WHERE class_name IS NOT NULL;
      UPDATE combine_taxa SET taxon_rank = 'order' WHERE "order" IS NOT NULL;
      UPDATE combine_taxa SET taxon_rank = 'family' WHERE family IS NOT NULL;
      UPDATE combine_taxa SET taxon_rank = 'genus' WHERE genus IS NOT NULL;
      UPDATE combine_taxa SET taxon_rank = 'species' WHERE species IS NOT NULL;
    SQL

    ActiveRecord::Base.connection.exec_query(sql)
  end

  task update_taxon_division: :environment do
    CombineTaxon.where(source: 'ncbi', cal_division_id: nil).each do |taxon|
      ncbi = NcbiNode.find(taxon.taxon_id)
      taxon.update(cal_division_id: ncbi.cal_division_id)
    end

    divisions = {
      Plantae: 14,
      Fungi: 13,
      Animalia: 12,
      Chromista: 17
    }
    CombineTaxon.where(source: 'gbif', cal_division_id: nil).each do |taxon|
      puts taxon.taxon_id
      gbif = GbifOccTaxa.find_by(taxonkey: taxon.taxon_id)
      division_id = divisions[gbif.kingdom.to_sym]

      taxon.update(cal_division_id: division_id)
    end
  end

  task check_non_ruggerio_taxa: :environment do
    include ImportGlobalNames
    global_names_api = ::GlobalNamesApi.new
    rank = ENV['rank']

    CSV.open("data/lookup_#{rank}_bg_genus.csv", 'a+') do |csv|
      csv << ['source', 'ct_genus', "gn_#{rank}", 'gn_names']
    end

    sql = <<-SQL
    SELECT DISTINCT genus
    FROM combine_taxa
    WHERE "#{rank}" NOT IN (
      SELECT DISTINCT("#{rank}") FROM combine_taxa
      WHERE source = 'paper' AND "#{rank}" IS NOT NULL
    )
    AND (source = 'gbif' OR source = 'ncbi')
    AND genus IS NOT NULL
    ORDER BY genus;
    SQL

    query_results = ActiveRecord::Base.connection.exec_query(sql)

    query_results.rows.flatten.each do |genus|
      next if genus.include?(' ')
      puts genus

      gn_request = global_names_api.names(genus)
      gn_results = gn_request['data'].first['results']
      next if gn_results.nil?

      gn_results.each do |row|
        ranks = row['classification_path_ranks'].split('|')
        rank_index = ranks.index(rank)
        next if rank_index.nil?

        names = row['classification_path'].split('|')
        rank_name = names[rank_index]

        source = row['data_source_title']

        ruggerio = CombineTaxon.where(source: 'paper', rank => rank_name)

        next if ruggerio.blank?

        CSV.open('data/lookup_order_bg_genus.csv', 'a+') do |csv|
          csv << [
            source, genus, rank_name, names.compact.join(', ')
          ]
        end
      end
    end
  end
end
